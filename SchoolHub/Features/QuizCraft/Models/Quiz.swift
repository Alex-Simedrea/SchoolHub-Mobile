//
//  Quiz.swift
//  QuizCraft
//
//  Created by Alexandru Simedrea on 11.12.2024.
//

import Foundation
import SwiftData

@Model
class Quiz {
    var title: String = ""
    var createdAt = Date()
    @Relationship var questionGroups: [QuestionGroup]? = []
    @Relationship var images: [QuizImage]? = []
    @Relationship var attempts: [Attempt]? = []
    var generation: Generation? = Generation()

    var unwrappedImages: [QuizImage] {
        images ?? []
    }

    var unwrappedQuestionGroups: [QuestionGroup] {
        questionGroups ?? []
    }

    var unwrappedAttempts: [Attempt] {
        attempts ?? []
    }

    var unwrappedGeneration: Generation {
        generation ?? Generation()
    }

    var questionsCount: Int {
        unwrappedQuestionGroups.reduce(0) { $0 + $1.count }
    }

    convenience init() {
        self.init(title: "", questionGroups: [])
    }

    init(
        title: String,
        questionGroups: [QuestionGroup],
        images: [QuizImage] = [],
        attempts: [Attempt] = [],
        generation: Generation = Generation()
    ) {
        self.title = title
        self.questionGroups = questionGroups
        self.images = images
        self.attempts = attempts
        self.generation = generation
    }
}

@Model
class QuizImage {
    var imageData: Data = Data()
    @Relationship(inverse: \Quiz.images) var quiz: Quiz?

    init(imageData: Data) {
        self.imageData = imageData
    }
}

struct Generation: Codable {
    var isGenerating: Bool = false
    var isGenerated: Bool = false
    var generatedQuestions: Int = 0
    var error: String?
}
