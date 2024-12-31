//
//  Attempt.swift
//  QuizCraft
//
//  Created by Alexandru Simedrea on 26.12.2024.
//

import Foundation
import SwiftData

@Model
class Attempt {
    var id = UUID()
    var date: Date = Date()
    var score: Int = 0
    @Relationship var questionGroups: [QuestionGroup]? = []
    var generatedAdvice: String?
    @Relationship(inverse: \Quiz.attempts) var quiz: Quiz?
    
    var unwrappedQuestionGroups: [QuestionGroup] {
        questionGroups ?? []
    }
    
    convenience init() {
        self.init(questionGroups: [])
    }
    
    init(
        date: Date = Date(),
        score: Int = 0,
        questionGroups: [QuestionGroup],
        generatedAdvice: String? = nil
    ) {
        self.date = date
        self.score = score
        self.questionGroups = questionGroups
        self.generatedAdvice = generatedAdvice
    }
}

@Model
class EvaluationResult {
    var isCorrect: Bool = false
    var score: Double = 0
    var feedback: String = ""
    var matchedCriteria: [String]?
    @Relationship(inverse: \Question.evaluationResult) var question: Question?

    init(isCorrect: Bool, score: Double, feedback: String, matchedCriteria: [String]? = nil) {
        self.isCorrect = isCorrect
        self.score = score
        self.feedback = feedback
        self.matchedCriteria = matchedCriteria
    }
}
