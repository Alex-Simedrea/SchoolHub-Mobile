//
//  AverageSubjectSimulation.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 23.11.2024.
//

import Foundation
import SwiftData

struct AverageSubjectSimulation: Identifiable {
    let subject: Subject // Reference to original subject
    var simulatedAverage: Int // Current average (simulated or real)
    let originalAverage: Double? // Keep track of original average
    
    var id: PersistentIdentifier { subject.id }
    var isSimulated: Bool { simulatedAverage != Int(round(originalAverage ?? -1)) }
    
    init(subject: Subject) {
        self.subject = subject
        self.originalAverage = subject.average
        self.simulatedAverage = Int(round(subject.average ?? 10))
    }
}
