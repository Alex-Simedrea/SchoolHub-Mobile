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
    @Attribute(.unique) var id = UUID()
    var name: String
    @Relationship(deleteRule: .cascade) var grades: [Grade]
    @Relationship(deleteRule: .cascade) var absences: [Absence]
    var color: SubjectColor
    var symbolName: String
    var displayName: String
    var hidden: Bool
    @Relationship(deleteRule: .cascade) var timeSlots: [TimeSlot] = []

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

extension Subject {
    func gradesAverage() -> Double {
        guard grades.count > 0 else { return 0 }
        return Double(grades.map(\.value).reduce(0, +)) / Double(grades.count)
    }

    func gradesCount() -> Int {
        grades.count
    }

    func excusedAbsencesCount() -> Int {
        absences.filter(\.excused).count
    }

    func unexcusedAbsencesCount() -> Int {
        absences.filter { !$0.excused }.count
    }

    func absencesCount() -> Int {
        absences.count
    }
}

//    @Published var subjects: [Subject] = []
//    = [
//        Subject(
//            name: "Matematica",
//            grades: [
//                Grade(
//                    value: 10,
//                    date: ISO8601DateFormatter().date(
//                        from: "2024-09-14T00:00:00+0000"
//                    )!
//                ),
//                Grade(
//                    value: 9,
//                    date: ISO8601DateFormatter().date(
//                        from: "2024-09-30T00:00:00+0000"
//                    )!
//                )
//            ],
//            absences: [
//                Absence(
//                    date: ISO8601DateFormatter().date(
//                        from: "2024-09-15T00:00:00+0000"
//                    )!,
//                    excused: false
//                )
//            ]
//        ),
//        Subject(
//            name: "Fizica",
//            grades: [
//                Grade(
//                    value: 8,
//                    date: ISO8601DateFormatter().date(
//                        from: "2024-09-14T00:00:00+0000"
//                    )!
//                )
//            ],
//            absences: []
//        ),
//        Subject(
//            name: "Informatica",
//            grades: [
//                Grade(
//                    value: 10,
//                    date: ISO8601DateFormatter().date(
//                        from: "2024-10-10T00:00:00+0000"
//                    )!
//                ),
//                Grade(
//                    value: 9,
//                    date: ISO8601DateFormatter().date(
//                        from: "2024-10-01T00:00:00+0000"
//                    )!
//                )
//            ],
//            absences: [
//                Absence(
//                    date: ISO8601DateFormatter().date(
//                        from: "2024-10-02T00:00:00+0000"
//                    )!,
//                    excused: true
//                )
//            ]
//        )
//    ]
