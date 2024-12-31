//
//  QuizView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 26.12.2024.
//

import GoogleGenerativeAI
import SwiftData
import SwiftUI
import Toasts

struct QuizScreen: View {
    let quiz: Quiz
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var viewModel = PhotoReasoningViewModel()
    @State private var attempt: Attempt = .init()
    
    @State private var isSubmitted = false
    @State private var isGeneratingAdvice = false
    @State private var isEvaluating = false
    
    @State private var scrollPosition: ScrollPosition = .init()
    
    private var answeredQuestions: Int {
        let choiceQuestions = attempt.unwrappedQuestionGroups.reduce(0) {
            $0 + $1.unwrappedQuestions.count(where: {
                $0.unwrappedAnswers.contains(where: {
                    $0.isSelected
                })
            })
        }
        
        let textQuestions = attempt.unwrappedQuestionGroups.reduce(0) {
            $0 + $1.unwrappedQuestions.count(where: {
                !$0.textAnswer.isEmpty
            })
        }
        
        return choiceQuestions + textQuestions
    }
    
    var body: some View {
        ScrollView {
            if isSubmitted {
                QuizResultsView(savedAttempt: attempt)
            } else {
                quizContent
            }
        }
        .scrollPosition($scrollPosition)
        .navigationTitle(quiz.title)
        .toolbar {
            ToolbarItem {
                NavigationLink {
                    QuizAttemptsScreen(quiz: quiz)
                } label: {
                    Text("Attempts")
                }
            }
        }
        .overlay {
            if isEvaluating {
                evaluationOverlay
            }
        }
        .onAppear {
            if !isSubmitted {
                print("shuffling")
                createAttempt()
            }
            sortAttempt()
        }
        .onChange(of: isSubmitted) {
            if isSubmitted {
                scrollPosition.scrollTo(edge: .top)
            }
        }
    }
    
    func sortAttempt() {
        attempt.questionGroups?.sort {
            if $0.difficulty == $1.difficulty {
                return $0.type.order < $1.type.order
            }
            
            return $0.difficulty.rawValue < $1.difficulty.rawValue
        }
    }
    
    func createAttempt() {
        attempt = .init(
            questionGroups: quiz.unwrappedQuestionGroups.map { group in
                .init(
                    difficulty: group.difficulty,
                    type: group.type,
                    count: group.count,
                    questions: group.unwrappedQuestions.map { question in
                        .init(
                            question: question.question,
                            answers: question.unwrappedAnswers
                                .map { answer in
                                    .init(
                                        text: answer.text,
                                        isCorrect: answer.isCorrect
                                    )
                                },
                            type: question.type,
                            evaluationCriteria: question.evaluationCriteria
                        )
                    }
                )
            }
        )
        
        attempt.questionGroups?.forEach { group in
            group.questions?.shuffle()
            group.questions?.forEach { question in
                if question.type != .trueFalse {
                    question.answers?.shuffle()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var quizContent: some View {
        LazyVStack(spacing: 20) {
            ForEach(attempt.unwrappedQuestionGroups) { group in
                QuestionGroupSection(group: group)
            }
            
            submitButton
        }
        .padding()
    }
    
    private var submitButton: some View {
        Button {
            Task {
                await submitQuiz()
            }
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Submit")
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 20))
        }
        .disabled(
            answeredQuestions != attempt.unwrappedQuestionGroups.questionsCount || isEvaluating
        )
    }
    
    private var evaluationOverlay: some View {
        ZStack {
            Color(.systemBackground).opacity(0.7)
                .ignoresSafeArea()
            
            ProgressView("Evaluating Answers...")
                .scaleEffect(1.5)
        }
    }
    
    // MARK: - Actions
    
    private func submitQuiz() async {
        isEvaluating = true
        defer { isEvaluating = false }
        
        var correctAnswers = 0
        
        for questionGroup in attempt.unwrappedQuestionGroups {
            for question in questionGroup.unwrappedQuestions {
                switch question.type {
                case .shortAnswer, .longAnswer:
                    let evaluation = await viewModel.evaluateTextAnswer(
                        userAnswer: question.textAnswer,
                        question: question
                    )
                        
                    question.evaluationResult = evaluation
                        
                    if evaluation.isCorrect {
                        correctAnswers += 1
                    }
                    
                case .multipleChoice, .singleChoice, .trueFalse:
                    if question.unwrappedAnswers
                        .allSatisfy({ $0.isCorrect == $0.isSelected })
                    {
                        correctAnswers += 1
                    }
                }
            }
        }
        
        attempt.score = Int(
            Double(correctAnswers) / Double(
                attempt.unwrappedQuestionGroups.questionsCount
            ) * 100
        )
        
        quiz.attempts?.append(attempt)
        
        try? modelContext.save()
        isSubmitted = true
    }
}

// MARK: - Supporting Views

struct QuizResultsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.presentToast) var presentToast
    @Bindable var savedAttempt: Attempt
    @State private var attempt: Attempt = .init()
    @State private var isGeneratingAdvice = false
    
    var body: some View {
        VStack(spacing: 20) {
            ScoreCard(score: attempt.score)
            
            ForEach(attempt.unwrappedQuestionGroups) { group in
                ResultQuestionGroupSection(group: group)
            }
            
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
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 20))
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
        .padding()
        .onAppear {
            attempt = .init(
                date: savedAttempt.date,
                score: savedAttempt.score,
                questionGroups: savedAttempt.unwrappedQuestionGroups.map { group in
                    .init(
                        difficulty: group.difficulty,
                        type: group.type,
                        count: group.count,
                        questions: group.unwrappedQuestions.map { question in
                            .init(
                                question: question.question,
                                answers: question.unwrappedAnswers.map { answer in
                                    .init(
                                        text: answer.text,
                                        isCorrect: answer.isCorrect,
                                        isSelected: answer.isSelected
                                    )
                                },
                                type: question.type,
                                evaluationCriteria: question.evaluationCriteria,
                                textAnswer: question.textAnswer,
                                evaluationResult: .init(
                                    isCorrect: question.evaluationResult?.isCorrect ?? false,
                                    score: question.evaluationResult?.score ?? 0,
                                    feedback: question.evaluationResult?.feedback ?? "",
                                    matchedCriteria: question.evaluationResult?.matchedCriteria
                                )
                            )
                        }
                    )
                },
                generatedAdvice: savedAttempt.generatedAdvice
            )
            
            sortAttempt()
        }
    }
    
    func sortAttempt() {
        attempt.questionGroups?.sort {
            if $0.difficulty == $1.difficulty {
                return $0.type.order < $1.type.order
            }
            
            return $0.difficulty.rawValue < $1.difficulty.rawValue
        }
    }
    
    private func generateAdvice() async {
        isGeneratingAdvice = true
        defer { isGeneratingAdvice = false }
        
        let summary = createQuizSummary()
        let prompt = createAdvicePrompt(with: summary)
        
        do {
            let model = GenerativeModel(
                name: "gemini-1.5-flash",
                apiKey: ""
            )
            
            let response = try await model.generateContent(prompt)
            attempt.generatedAdvice = response.text
            savedAttempt.generatedAdvice = response.text
            
            try? modelContext.save()
        } catch {
            let toast = ToastValue(
                icon: Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red),
                message: "Failed to generate advice"
            )
            presentToast(toast)
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

struct QuestionGroupSection: View {
    @Bindable var group: QuestionGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(group.difficulty.rawValue) - \(group.type.rawValue)")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(group.unwrappedQuestions) { question in
                QuestionView(question: question)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }
}

struct QuestionView: View {
    @Bindable var question: Question
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.question)
                .font(.headline)
            
            switch question.type {
            case .singleChoice, .trueFalse:
                ForEach(question.unwrappedAnswers) { answer in
                    ChoiceAnswerRow(
                        answer: answer,
                        isSelected: answer.isSelected,
                        onSelect: {
                            withAnimation {
                                question.unwrappedAnswers.forEach { $0.isSelected = false }
                                answer.isSelected = true
                            }
                        }
                    )
                }
                
            case .multipleChoice:
                ForEach(question.unwrappedAnswers) { answer in
                    ChoiceAnswerRow(
                        answer: answer,
                        isSelected: answer.isSelected,
                        onSelect: {
                            withAnimation {
                                answer.isSelected.toggle()
                            }
                        }
                    )
                }
                
            case .shortAnswer, .longAnswer:
                TextEditor(text: $question.textAnswer)
                    .frame(height: question.type == .shortAnswer ? 100 : 300)
                    .padding(8)
            }
        }
    }
}

struct ChoiceAnswerRow: View {
    let answer: Answer
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : .gray)
                Text(answer.text)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected
                            ? Color.accentColor.opacity(0.1)
                            : Color.secondary.opacity(0.05)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ResultQuestionGroupSection: View {
    let group: QuestionGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(group.difficulty.rawValue) - \(group.type.rawValue)")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(group.unwrappedQuestions) { question in
                QuestionResultView(question: question)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }
}

struct QuestionResultView: View {
    let question: Question
    
    var isCorrect: Bool {
        switch question.type {
        case .shortAnswer, .longAnswer:
            return question.evaluationResult?.isCorrect ?? false
        case .singleChoice, .trueFalse, .multipleChoice:
            return question.unwrappedAnswers.allSatisfy { $0.isCorrect == $0.isSelected }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(question.question)
                    .font(.headline)
                Spacer()
                ResultBadge(isCorrect: isCorrect)
            }
            
            if question.type == .shortAnswer || question.type == .longAnswer {
                Text("Your Answer:")
                    .font(.subheadline)
                Text(question.textAnswer)
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 8))
                
                if let evaluation = question.evaluationResult {
                    Text("Score: ")
                        .font(.headline)
                        + Text("\(Int(evaluation.score * 100))%")
                    
                    Text("Feedback")
                        .font(.headline)
                    Text(.init(evaluation.feedback))
                }
            } else {
                ForEach(question.unwrappedAnswers) { answer in
                    HStack {
                        Text(answer.text)
                        Spacer()
                        if answer.isSelected {
                            Image(systemName: "hand.point.left.fill")
                                .foregroundStyle(Color.accentColor)
                        }
                        if answer.isCorrect {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                        if answer.isSelected && !answer.isCorrect {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(getAnswerBackgroundColor(answer: answer))
                    )
                }
            }
        }
    }
    
    private func getAnswerBackgroundColor(answer: Answer) -> Color {
        if answer.isCorrect && answer.isSelected {
            return .green.opacity(0.15)
        } else if answer.isCorrect {
            return .green.opacity(0.1)
        } else if answer.isSelected {
            return .red.opacity(0.1)
        }
        return .secondary.opacity(0.05)
    }
}

struct ResultBadge: View {
    let isCorrect: Bool
    
    var body: some View {
        Label(
            isCorrect ? "Correct" : "Incorrect",
            systemImage: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
        )
        .foregroundStyle(isCorrect ? .green : .red)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        )
    }
}

struct ScoreCard: View {
    let score: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Your Score")
                .font(.headline)
            Text("\(score)%")
                .font(.system(size: 48, weight: .bold))
            Text(getScoreMessage())
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(scoreColor().opacity(0.2))
        .cornerRadius(15)
    }
    
    private func scoreColor() -> Color {
        switch score {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .yellow
        default: return .red
        }
    }
    
    private func getScoreMessage() -> String {
        switch score {
        case 90...100: return "Excellent!"
        case 70..<90: return "Good job!"
        case 50..<70: return "Not bad"
        default: return "Keep practicing"
        }
    }
}

struct AdviceView: View {
    let advice: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Learning Advice", systemImage: "lightbulb.fill")
                .font(.headline)
            Text(.init(advice))
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(10)
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
