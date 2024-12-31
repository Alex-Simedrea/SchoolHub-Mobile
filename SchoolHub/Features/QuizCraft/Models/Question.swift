//
//  Question.swift
//  QuizCraft
//
//  Created by Alexandru Simedrea on 11.12.2024.
//

import Foundation
import SwiftData

@Model
class Question {
    var question: String = ""
    var type: QuestionType = QuestionType.singleChoice

    @Relationship var answers: [Answer]? = []

    var evaluationCriteria: [String] = []
    var textAnswer: String = ""
    @Relationship var evaluationResult: EvaluationResult?

    @Relationship(inverse: \QuestionGroup.questions) var questionGroup: QuestionGroup?

    var unwrappedAnswers: [Answer] {
        answers ?? []
    }

    init(
        question: String,
        answers: [Answer],
        type: QuestionType,
        evaluationCriteria: [String] = [],
        textAnswer: String = "",
        evaluationResult: EvaluationResult? = nil
    ) {
        self.question = question
        self.answers = answers
        self.type = type
        self.evaluationCriteria = evaluationCriteria
        self.textAnswer = textAnswer
        self.evaluationResult = evaluationResult
    }
}

@Model
class Answer {
    var text: String = ""
    var isCorrect: Bool = true
    var isSelected: Bool = false
    @Relationship(inverse: \Question.answers) var question: Question?

    init(text: String, isCorrect: Bool, isSelected: Bool = false) {
        self.text = text
        self.isCorrect = isCorrect
        self.isSelected = isSelected
    }
}

enum QuestionType: String, Codable, CaseIterable {
    case singleChoice = "Single Choice"
    case multipleChoice = "Multiple Choice"
    case trueFalse = "True or False"
    case shortAnswer = "Short Answer"
    case longAnswer = "Long Answer"

    var order: Int {
        switch self {
        case .singleChoice:
            return 0
        case .multipleChoice:
            return 1
        case .trueFalse:
            return 2
        case .shortAnswer:
            return 3
        case .longAnswer:
            return 4
        }
    }
}
