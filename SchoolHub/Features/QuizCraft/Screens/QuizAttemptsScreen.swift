//
//  QuizAttemptsView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 26.12.2024.
//

import GoogleGenerativeAI
import SwiftUI

struct QuizAttemptsScreen: View {
    let quiz: Quiz
    
    var body: some View {
        List {
            ForEach(
                quiz.unwrappedAttempts.sorted(by: { $0.date > $1.date })
            ) { attempt in
                NavigationLink(destination: AttemptDetailView(attempt: attempt, quiz: quiz)) {
                    AttemptRow(attempt: attempt)
                }
            }
        }
        .navigationTitle("Attempt History")
    }
}

struct AttemptRow: View {
    let attempt: Attempt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(attempt.date, style: .date) + Text(", ") + Text(attempt.date, style: .time)
                Spacer()
                Text("\(attempt.score)%")
                    .bold()
                    .foregroundColor(scoreColor(attempt.score))
            }
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 90 ... 100: return .green
        case 70..<90: return .blue
        case 50..<70: return .yellow
        default: return .red
        }
    }
}

struct AttemptDetailView: View {
    let attempt: Attempt
    let quiz: Quiz
    @Environment(\.modelContext) private var modelContext
    @State private var isGeneratingAdvice = false
    
    var body: some View {
        ScrollView {
            resultsContent
        }
        .navigationTitle("Attempt Details")
    }
    
    private var resultsContent: some View {
        VStack(spacing: 20) {
            ScoreCard(score: attempt.score)
            
            ForEach(attempt.unwrappedQuestionGroups) { group in
                ResultQuestionGroupSection(group: group)
            }
            
            adviceSection
        }
        .padding()
    }
    
    private var adviceSection: some View {
        Group {
            if let advice = attempt.generatedAdvice {
                AdviceView(advice: advice)
            } else if !isGeneratingAdvice {
                Button {
                    Task {
                        await generateAdvice()
                    }
                } label: {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                        Text("Get learning advice")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.primary)
                    .foregroundStyle(.background)
                    .clipShape(.rect(cornerRadius: 20))
                    .padding()
                }
            } else {
                VStack {
                    ProgressView("Generating advice...")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
    
    private func generateAdvice() async {
        isGeneratingAdvice = true
        defer { isGeneratingAdvice = false }
        
        let summary = createQuizSummary()
        let prompt = createAdvicePrompt(with: summary)
        
        do {
            let model = GenerativeModel(
                name: "gemini-2.0-flash-exp",
                apiKey: ""
            )
            
            let response = try await model.generateContent(prompt)
            attempt.generatedAdvice = response.text
            
            // MARK: If saving is not working, try o get the attempt from the quiz and update it from there
            
            try? modelContext.save()
        } catch {
            // MARK: Add regenerate button
            
            attempt.generatedAdvice = "Error generating advice"
            print("Error generating advice: \(error)")
        }
    }
    
    private func createQuizSummary() -> String {
        var summary = "Quiz Results Summary:\n"
        summary += "Overall Score: \(attempt.score)%\n\n"
        
        for group in attempt.unwrappedQuestionGroups {
            for question in group.unwrappedQuestions {
                summary += "Question: \(question.question)\n"
                summary += "Type: \(question.type.rawValue)\n"
                summary += "Difficulty: \(group.difficulty.rawValue)\n"
                
                switch question.type {
                case .shortAnswer, .longAnswer:
                    if let evaluation = question.evaluationResult {
                        summary += "Answer: \(question.textAnswer)\n"
                        summary += "Score: \(Int(evaluation.score * 100))%\n"
                        summary += "Feedback: \(evaluation.feedback)\n"
                    }
                case .multipleChoice, .singleChoice, .trueFalse:
                    summary += "Selected: \(question.unwrappedAnswers.filter { $0.isSelected }.map(\.text).joined(separator: ", "))\n"
                    summary += "Correct: \(question.unwrappedAnswers.filter { $0.isCorrect }.map(\.text).joined(separator: ", "))\n"
                }
                summary += "\n"
            }
        }
        
        return summary
    }
    
    private func createAdvicePrompt(with summary: String) -> String {
        """
        Based on the following quiz results, provide personalized learning advice.
        Focus on:
        1. Areas where improvement is needed
        2. Specific concepts to review
        3. Study strategies
        4. Positive reinforcement
        5. Next steps
        
        Keep the advice:
        - Constructive and encouraging
        - Specific and actionable
        - Clear and organized
        - Focused on improvement
        
        Quiz Results:
        \(summary)
        """
    }
}
