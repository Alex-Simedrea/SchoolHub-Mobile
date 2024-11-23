//
//  Subject.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import Foundation
import SwiftData
import SwiftUI

enum SubjectColor: String, Codable, Identifiable, CaseIterable {
    case red
    case blue
    case green
    case yellow
    case purple
    case orange
    case pink
    case mint
    case teal
    case cyan
    case indigo
    case brown

    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .purple: return .purple
        case .orange: return .orange
        case .pink: return .pink
        case .mint: return .mint
        case .teal: return .teal
        case .cyan: return .cyan
        case .indigo: return .indigo
        case .brown: return .brown
        }
    }

    var name: String {
        rawValue.capitalized
    }

    var id: String { name }
}

@Model
class Subject {
//    var id = UUID()
    var name: String = ""
    @Relationship(deleteRule: .cascade) var grades: [Grade]? = []
    @Relationship(deleteRule: .cascade) var absences: [Absence]? = []
    var color: SubjectColor = SubjectColor.blue
    var symbolName: String = "graduationcap.fill"
    var displayName: String = ""
    var hidden: Bool = false
    @Relationship(deleteRule: .cascade) var timeSlots: [TimeSlot]? = []
    
    var unwrappedGrades: [Grade] {
        grades ?? []
    }
    
    var unwrappedAbsences: [Absence] {
        absences ?? []
    }
    
    var unwrappedTimeSlots: [TimeSlot] {
        timeSlots ?? []
    }
    
    var average: Double? {
        guard !unwrappedGrades.isEmpty else { return nil }
        return unwrappedGrades.map { Double($0.value) }.reduce(0, +) / Double(unwrappedGrades.count)
    }

    init(
        name: String,
        grades: [Grade],
        absences: [Absence],
        color: SubjectColor = SubjectColor.blue,
        symbolName: String = "graduationcap.fill",
        displayName: String? = nil,
        hidden: Bool = false,
        timeSlots: [TimeSlot] = []
    ) {
        self.name = name
        self.grades = grades
        self.absences = absences
        self.color = color
        self.symbolName = symbolName
        self.displayName = displayName ?? name
        self.hidden = hidden
        self.timeSlots = timeSlots
    }
}
