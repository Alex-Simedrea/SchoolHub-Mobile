//
//  SubjectAverageViewModel.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 23.11.2024.
//

import Foundation

class SubjectAverageViewModel: ObservableObject {
    private let averagesViewModel: AveragesViewModel
    private let subject: Subject
    @Published var simulation: GradesSubjectSimulation
    @Published var targetAverage: Int
    
    init(subject: Subject, targetAverage: Int?, averagesViewModel: AveragesViewModel) {
        self.subject = subject
        self.averagesViewModel = averagesViewModel
        self.simulation = averagesViewModel.getSimulation(for: subject)
        self.targetAverage = targetAverage ?? 10
    }
    
    func addSimulatedGrade(_ grade: Int) {
        simulation.simulatedGrades.append(GradeSimulation(value: grade, isSimulated: true))
        averagesViewModel.updateSimulation(simulation, for: subject)
    }
    
    func removeSimulatedGrade(withID id: UUID) {
        simulation.simulatedGrades.removeAll { $0.id == id }
        averagesViewModel.updateSimulation(simulation, for: subject)
    }
    
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
            tempSubject = simulation
        }
        
        return suggestions.sorted { s1, s2 in
            if s1.count == s2.count {
                return s1.grade < s2.grade
            }
            return s1.count < s2.count
        }
    }
}
