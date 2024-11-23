//
//  SubjectAverageViewModel.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 23.11.2024.
//

import Foundation

class SubjectAverageViewModel: ObservableObject {
    @Published var simulation: GradesSubjectSimulation
    @Published var targetAverage: Int
    
    struct GradeSuggestion: Identifiable {
        let id = UUID()
        let count: Int
        let grade: Int
        
        var description: String {
            if count == 1 {
                return "One \(grade) or higher grade"
            } else {
                return "\(count) grades of \(grade)"
            }
        }
    }
    
    var improvementSuggestions: [GradeSuggestion] {
        let currentAverage = simulation.average
        var tempSubject = simulation
        if targetAverage <= currentAverage { return [] }
        
        var suggestions: [GradeSuggestion] = []
        
        for grade in 1...10 {
            for count in 1...10 {
                for _ in 0 ..< count {
                    tempSubject.simulatedGrades.append(GradeSimulation(value: grade, isSimulated: true))
                }
                
                if tempSubject.average >= targetAverage {
                    if !suggestions.contains(where: { $0.count == count }) {
                        suggestions.append(GradeSuggestion(count: count, grade: grade))
                    }
                    break
                }
                
                tempSubject = simulation
            }
        }
        
        return suggestions.sorted { s1, s2 in
            if s1.count == s2.count {
                return s1.grade < s2.grade
            }
            return s1.count < s2.count
        }
    }
    
    init(subject: Subject, targetAverage: Int?) {
        self.simulation = GradesSubjectSimulation(subject: subject)
        self.targetAverage = targetAverage ?? 10
    }
}
