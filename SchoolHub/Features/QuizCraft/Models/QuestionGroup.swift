//
//  QuestionGroup.swift
//  QuizCraft
//
//  Created by Alexandru Simedrea on 11.12.2024.
//

import Foundation
import SwiftData

@Model
class QuestionGroup {
    var difficulty: QuestionDifficulty = QuestionDifficulty.easy
    var type: QuestionType = QuestionType.singleChoice
    var count: Int = 1
    @Relationship var questions: [Question]? = []

    @Relationship(inverse: \Quiz.questionGroups) var quiz: Quiz?
    @Relationship(inverse: \Attempt.questionGroups) var attempt: Attempt?

    var unwrappedQuestions: [Question] {
        questions ?? []
    }

    init(
        difficulty: QuestionDifficulty,
        type: QuestionType,
        count: Int,
        questions: [Question]
    ) {
        self.difficulty = difficulty
        self.type = type
        self.count = count
        self.questions = questions
    }
}

enum QuestionDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

extension [QuestionGroup] {
    var questionsCount: Int {
        self.reduce(0) { $0 + $1.unwrappedQuestions.count }
    }
}
