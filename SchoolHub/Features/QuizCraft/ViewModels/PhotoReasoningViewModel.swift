import Foundation
import GoogleGenerativeAI
import OSLog
import PhotosUI
import SwiftData
import SwiftUI

@MainActor
class PhotoReasoningViewModel: ObservableObject {
    private static let largestImageDimension = 768.0
    @Published var selectedItems = [PhotosPickerItem]()
    
    let questionSchema = Schema(
        type: .array,
        description: "Array of questions based on the content",
        items: Schema(
            type: .object,
            properties: [
                "question": Schema(type: .string, description: "The question text"),
                "answers": Schema(
                    type: .array,
                    description: "Array of answers with correctness",
                    items: Schema(
                        type: .object,
                        properties: [
                            "text": Schema(type: .string, description: "Answer text"),
                            "isCorrect": Schema(type: .boolean, description: "Whether this answer is correct")
                        ],
                        requiredProperties: ["text", "isCorrect"]
                    )
                ),
                "evaluationCriteria": Schema(
                    type: .array,
                    description: "Key points for evaluating text answers",
                    items: Schema(type: .string)
                )
            ],
            requiredProperties: ["question", "answers"]
        )
    )
    
    // Text evaluation model with its schema
    let evaluationSchema = Schema(
        type: .object,
        properties: [
            "isCorrect": Schema(type: .boolean, description: "Whether the answer meets the criteria"),
            "score": Schema(type: .number, description: "Score between 0 and 1"),
            "feedback": Schema(type: .string, description: "Brief explanation of the evaluation"),
            "matchedCriteria": Schema(
                type: .array,
                description: "List of criteria that were met",
                items: Schema(type: .string)
            )
        ],
        requiredProperties: ["isCorrect", "score", "feedback"]
    )
    
    struct GeneratedQuestion: Codable {
        let question: String
        let answers: [GeneratedAnswer]
        let evaluationCriteria: [String]?
        
        struct GeneratedAnswer: Codable {
            let text: String
            let isCorrect: Bool
        }
    }
    
    struct EvaluationResponse: Codable {
        let isCorrect: Bool
        let score: Double
        let feedback: String
        let matchedCriteria: [String]?
    }
    
    func processSelectedItems() async throws -> [QuizImage] {
        var quizImages: [QuizImage] = []
        
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self) {
                guard let image = UIImage(data: data) else { continue }
                
                let processedImage: UIImage
                if image.size.fits(largestDimension: Self.largestImageDimension) {
                    processedImage = image
                } else {
                    guard let resizedImage = image.preparingThumbnail(of: image.size
                        .aspectFit(largestDimension: Self.largestImageDimension))
                    else { continue }
                    processedImage = resizedImage
                }
                
                if let processedData = processedImage.jpegData(compressionQuality: 0.8) {
                    quizImages.append(QuizImage(imageData: processedData))
                }
            }
        }
        
        return quizImages
    }
    
    func generateQuestions(for quiz: Quiz) async {
        print("\(quiz.unwrappedGeneration)")
        guard !quiz.unwrappedGeneration.isGenerated else {
            print("Quiz already generated, skipping")
            return
        }
        
        quiz.generation?.isGenerating = true
        defer { quiz.generation?.isGenerating = false }
        
        do {
            print(
                "Generating questions for \(quiz.unwrappedQuestionGroups.count) groups"
            )
            for group in quiz.unwrappedQuestionGroups {
                print("Generating questions for group: \(group.type.rawValue)")
                let questions = try await generateQuestions(for: group, using: quiz)
                group.questions = questions
                
                withAnimation {
                    quiz.generation?.generatedQuestions += questions.count
                }
                print("Generated \(questions.count) questions")
            }
            
            quiz.generation?.error = nil
            quiz.generation?.isGenerated = true
            print("Quiz generation completed")
        } catch {
            print("Error generating questions: \(error.localizedDescription)")
            quiz.generation?.error = error.localizedDescription
            quiz.generation?.generatedQuestions = 0
        }
    }
    
    func generateQuestions(for questionGroup: QuestionGroup, using quiz: Quiz) async throws -> [Question] {
        let model = GenerativeModel(
            name: "gemini-1.5-flash",
            apiKey: "",
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: questionSchema
            )
        )
        
        guard !quiz.unwrappedImages.isEmpty else {
            print("No images available")
            throw NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No images available"]
            )
        }
        
        let promptTemplate: String
        
        switch questionGroup.type {
        case .singleChoice:
            promptTemplate = """
            Generate \(questionGroup.count) single-choice questions based on the provided image(s).
            Requirements:
            - Questions should be of \(questionGroup.difficulty.rawValue) difficulty
            - Each question must have exactly 4 possible answers
            - Only one answer should be correct
            - Answers should be clear and unambiguous
            - Questions must test understanding, not just observation
            - Return the correct answer index (0-3)
            """
            
        case .multipleChoice:
            promptTemplate = """
            Generate \(questionGroup.count) multiple-choice questions based on the provided image(s).
            Requirements:
            - Questions should be of \(questionGroup.difficulty.rawValue) difficulty
            - Each question must have exactly 4 possible answers
            - There must be at least 2 correct answers and maximum 3 correct answers for each question
            - Each question should be formulated such that it can accept more than one correct answer
            - Each answer should be distinct and not overlapping with the others
            - Return an array of correct answer indices (0-3)
            - Answers should be clear and unambiguous
            - Questions must test understanding, not just observation
            """
            
        case .trueFalse:
            promptTemplate = """
            Generate \(questionGroup.count) true/false questions based on the provided image(s).
            Requirements:
            - Questions should be of \(questionGroup.difficulty.rawValue) difficulty
            - Each question must have exactly 2 answers: "True" and "False"
            - Return the correct answer index (0 for True, 1 for False)
            - Questions must be definitively true or false based on the image
            - Questions must test understanding, not just observation
            """
            
        case .shortAnswer:
            promptTemplate = """
            Generate \(questionGroup.count) short-answer questions based on the provided image(s).
            Requirements:
            - Questions should be of \(questionGroup.difficulty.rawValue) difficulty
            - Questions should be answerable in 1-2 sentences
            - Provide a model answer for evaluation purposes
            - Questions must test understanding, not just observation
            - Include evaluation criteria with key points that must be present
            """
            
        case .longAnswer:
            promptTemplate = """
            Generate \(questionGroup.count) long-answer questions based on the provided image(s).
            Requirements:
            - Questions should be of \(questionGroup.difficulty.rawValue) difficulty
            - Questions should require detailed explanations (1-2 paragraphs)
            - Provide a model answer for evaluation purposes
            - Questions must test deep understanding and analysis
            - Include evaluation criteria with:
              * Main arguments/points that must be covered
              * Key concepts that should be discussed
              * Required evidence or examples from the image
            """
        }
        
        var images: [any ThrowingPartsRepresentable] = []
        for quizImage in quiz.unwrappedImages {
            if let uiImage = UIImage(data: quizImage.imageData) {
                images.append(uiImage)
            }
        }
        
        print("Processing \(images.count) images")
        
        do {
            print("Sending request to model")
            let response = try await model.generateContent(promptTemplate, images)
            print("Received response from model")
            
            guard let jsonString = response.text else {
                print("No text in response")
                throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No response from model"]
                )
            }
            
            print("Response text: \(jsonString)")
            
            let decoder = JSONDecoder()
            let questionData = Data(jsonString.utf8)
            let generatedQuestions = try decoder.decode([GeneratedQuestion].self, from: questionData)
            print("Decoded \(generatedQuestions.count) questions")
            
            return generatedQuestions.prefix(questionGroup.count).map { generated in
                Question(
                    question: generated.question,
                    answers: generated.answers.map { Answer(text: $0.text, isCorrect: $0.isCorrect) },
                    type: questionGroup.type,
                    evaluationCriteria: generated.evaluationCriteria ?? []
                )
            }
        } catch {
            print("Error in generation: \(error.localizedDescription)")
            throw error
        }
    }
    
    func evaluateTextAnswer(userAnswer: String, question: Question) async -> EvaluationResult {
        let model = GenerativeModel(
            name: "gemini-1.5-flash",
            apiKey: "",
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: evaluationSchema
            )
        )
        
        let prompt = """
        Evaluate if the following answer is correct based on these criteria.
        
        Question: \(question.question)
        Question Type: \(question.type.rawValue)
        Model Answer: \(question.unwrappedAnswers.first?.text ?? "")
        User's Answer: \(userAnswer)
        
        Evaluation Criteria:
        \(question.evaluationCriteria.enumerated().map { "- \($0.1)" }.joined(separator: "\n"))
        
        For Short Answer:
        - Check if key concepts are present
        - Verify factual accuracy
        - Ensure answer is concise and relevant
        
        For Long Answer:
        - Evaluate depth of analysis
        - Check for all required main points
        - Assess use of evidence/examples
        - Consider clarity and organization
        
        Refer to the user using the second person (you/your) in feedback.
        Return evaluation results in the specified JSON format.
        """
        
        do {
            let response = try await model.generateContent(prompt)
            if let jsonString = response.text,
               let jsonData = jsonString.data(using: .utf8)
            {
                let evaluation = try JSONDecoder().decode(EvaluationResponse.self, from: jsonData)
                return EvaluationResult(
                    isCorrect: evaluation.isCorrect,
                    score: evaluation.score,
                    feedback: evaluation.feedback,
                    matchedCriteria: evaluation.matchedCriteria
                )
            }
            return EvaluationResult(
                isCorrect: false,
                score: 0,
                feedback: "Failed to parse evaluation response",
                matchedCriteria: nil
            )
        } catch {
            print("Error evaluating text answer: \(error)")
            return EvaluationResult(
                isCorrect: false,
                score: 0,
                feedback: "Error evaluating answer: \(error.localizedDescription)",
                matchedCriteria: nil
            )
        }
    }
}

// MARK: - Helper Extensions

extension CGSize {
    func fits(largestDimension length: CGFloat) -> Bool {
        return width <= length && height <= length
    }
    
    func aspectFit(largestDimension length: CGFloat) -> CGSize {
        let aspectRatio = width / height
        if width > height {
            let width = min(self.width, length)
            return CGSize(width: width, height: round(width / aspectRatio))
        } else {
            let height = min(self.height, length)
            return CGSize(width: round(height * aspectRatio), height: height)
        }
    }
}
