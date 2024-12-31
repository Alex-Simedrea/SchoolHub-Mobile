//
//  AveragesViewModel.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 23.11.2024.
//

import Foundation
import SwiftData
import SwiftUI

class AveragesViewModel: ObservableObject {
    @AppStorage("TargetOverallAverage") var targetOverallAverage: Double = 10
    @Published var simulatedSubjects: [AverageSubjectSimulation] = []
    @Published var subjectSimulations: [PersistentIdentifier: GradesSubjectSimulation] = [:]
    
    func updateSimulations(with subjects: [Subject]) {
        simulatedSubjects = subjects.map { AverageSubjectSimulation(subject: $0) }
        
        // Initialize grade simulations for each subject if not exists
        for subject in subjects {
            if subjectSimulations[subject.id] == nil {
                subjectSimulations[subject.id] = GradesSubjectSimulation(subject: subject)
            }
        }
    }
    
    func getSimulation(for subject: Subject) -> GradesSubjectSimulation {
        if let simulation = subjectSimulations[subject.id] {
            return simulation
        }
        let newSimulation = GradesSubjectSimulation(subject: subject)
        subjectSimulations[subject.id] = newSimulation
        return newSimulation
    }
    
    func updateSimulation(_ simulation: GradesSubjectSimulation, for subject: Subject) {
        subjectSimulations[subject.id] = simulation
        // Update the corresponding simulated subject's average
        if let index = simulatedSubjects.firstIndex(where: { $0.id == subject.id }) {
            simulatedSubjects[index].simulatedAverage = simulation.average
        }
    }
    
    func resetAll() {
        // Reset all simulated subjects to their original averages
        simulatedSubjects = simulatedSubjects.map { subject in
            var resetSubject = subject
            resetSubject.simulatedAverage = Int(round(subject.originalAverage ?? 10))
            return resetSubject
        }
        
        // Clear all simulated grades
        subjectSimulations = [:]
        
        // Reinitialize empty simulations
        for subject in simulatedSubjects.map({ $0.subject }) {
            subjectSimulations[subject.id] = GradesSubjectSimulation(subject: subject)
        }
    }
    
    var overallAverage: Double {
        guard !simulatedSubjects.isEmpty else { return 0 }
        let sum = simulatedSubjects.map { Double($0.simulatedAverage) }.reduce(0.0, +)
        return sum / Double(simulatedSubjects.count)
    }
    
    func updateSubjectSimulation(subject: Subject, simulatedAverage: Int?) {
        if let index = simulatedSubjects.firstIndex(where: { $0.id == subject.id }) {
            simulatedSubjects[index].simulatedAverage = simulatedAverage ?? Int(round(subject.average ?? 10))
        }
    }
    
    struct SubjectImprovement {
        let simulatedSubject: AverageSubjectSimulation
        let targetAverage: Int
        let suggestions: [SubjectAverageViewModel.GradeSuggestion]
        
        var easiestSuggestion: SubjectAverageViewModel.GradeSuggestion? {
            suggestions.first
        }
    }
    
    var pointsNeeded: Int {
        let currentSum = simulatedSubjects.map { Double($0.simulatedAverage) }.reduce(0.0, +)
        let targetSum = targetOverallAverage * Double(simulatedSubjects.count)
        return Int(ceil(targetSum - currentSum))
    }
    
    var improvementSuggestions: [(AverageSubjectSimulation, Int)] {
        if pointsNeeded <= 0 || targetOverallAverage > 10 { return [] }
        
        // Get subjects that can improve
        let improvableSubjects = simulatedSubjects
            .filter { $0.simulatedAverage < 10 }
            .sorted { $0.simulatedAverage > $1.simulatedAverage }
        
        var improvements: [SubjectImprovement] = []
        var remainingPoints = pointsNeeded
        var currentSubjectIndex = 0
        
        // First try to improve subjects by one point
        while remainingPoints > 0 && currentSubjectIndex < improvableSubjects.count {
            let simSubject = improvableSubjects[currentSubjectIndex]
            let targetAverage = min(simSubject.simulatedAverage + 1, 10)
            
            let viewModel = SubjectAverageViewModel(
                subject: simSubject.subject,
                targetAverage: targetAverage,
                averagesViewModel: .init()
            )
            viewModel.targetAverage = targetAverage
            
            improvements.append(SubjectImprovement(
                simulatedSubject: simSubject,
                targetAverage: targetAverage,
                suggestions: viewModel.improvementSuggestions
            ))
            remainingPoints -= 1
            currentSubjectIndex += 1
        }
        
        // If we still need points, try increasing targets further
        if remainingPoints > 0 {
            for improvement in improvements {
                let simSubject = improvement.simulatedSubject
                let possibleIncrease = 10 - simSubject.simulatedAverage
                
                if possibleIncrease > 1 {
                    let additionalIncrease = min(possibleIncrease - 1, remainingPoints)
                    let newTargetAverage = simSubject.simulatedAverage + additionalIncrease + 1
                    
                    let viewModel = SubjectAverageViewModel(
                        subject: simSubject.subject,
                        targetAverage: newTargetAverage,
                        averagesViewModel: .init()
                    )
                    viewModel.targetAverage = newTargetAverage
                    
//                    if !viewModel.improvementSuggestions.isEmpty {
                    improvements = improvements.map {
                        if $0.simulatedSubject.id == simSubject.id {
                            return SubjectImprovement(
                                simulatedSubject: simSubject,
                                targetAverage: newTargetAverage,
                                suggestions: viewModel.improvementSuggestions
                            )
                        }
                        return $0
                    }
                    remainingPoints -= additionalIncrease
//                    }
                    
                    if remainingPoints == 0 { break }
                }
            }
        }
        
        return improvements
            .sorted { imp1, imp2 in
                guard let sug1 = imp1.easiestSuggestion,
                      let sug2 = imp2.easiestSuggestion
                else {
                    return false
                }
                if sug1.count == sug2.count {
                    return sug1.grade < sug2.grade
                }
                return sug1.count < sug2.count
            }
            .map {
                (
                    $0.simulatedSubject,
                    $0.targetAverage - $0.simulatedSubject.simulatedAverage
                )
            }
    }
}
