//
//  GradesSubjectSimulation.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 23.11.2024.
//

import Foundation

struct GradesSubjectSimulation {
    let subject: Subject // Reference to SwiftData Subject
    var simulatedGrades: [GradeSimulation]
    var targetAverage: Int?
    
    var allGrades: [GradeSimulation] {
        let existingGrades = subject.unwrappedGrades.map {
            GradeSimulation(value: $0.value, isSimulated: false)
        }
        return existingGrades + simulatedGrades
    }
    
    var average: Int {
        guard !allGrades.isEmpty else { return 10 }
        let sum = Double(allGrades.map { $0.value }.reduce(0, +))
        let avg = (sum / Double(allGrades.count)).rounded()
        return Int(avg)
    }
    
    init(subject: Subject) {
        self.subject = subject
        self.simulatedGrades = []
    }
}

struct GradeSimulation: Identifiable {
    let id = UUID()
    let value: Int
    let isSimulated: Bool
}
