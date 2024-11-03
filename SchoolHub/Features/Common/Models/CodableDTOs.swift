//
//  CodableDTOs.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 03.11.2024.
//

import Foundation

struct SubjectDTO: Codable {
    var id: UUID
    var name: String
    var grades: [GradeDTO]
    var absences: [AbsenceDTO]
    var color: SubjectColor
    var symbolName: String
    var displayName: String
    var hidden: Bool
    var timeSlots: [TimeSlotDTO]
    
    init(from subject: Subject) {
        self.id = subject.id
        self.name = subject.name
        self.grades = subject.grades.map(GradeDTO.init)
        self.absences = subject.absences.map(AbsenceDTO.init)
        self.color = subject.color
        self.symbolName = subject.symbolName
        self.displayName = subject.displayName
        self.hidden = subject.hidden
        self.timeSlots = subject.timeSlots.map(TimeSlotDTO.init)
    }
}

struct GradeDTO: Codable {
    var id: UUID
    var value: Int
    var date: Date
    
    init(from grade: Grade) {
        self.id = grade.id
        self.value = grade.value
        self.date = grade.date
    }
}

struct AbsenceDTO: Codable {
    var id: UUID
    var date: Date
    var excused: Bool
    
    init(from absence: Absence) {
        self.id = absence.id
        self.date = absence.date
        self.excused = absence.excused
    }
}

struct TimeSlotDTO: Codable {
    var id: UUID
    var weekday: Weekday
    var startTime: Date
    var endTime: Date
    var location: String?
    
    init(from timeSlot: TimeSlot) {
        self.id = timeSlot.id
        self.weekday = timeSlot.weekday
        self.startTime = timeSlot.startTime
        self.endTime = timeSlot.endTime
        self.location = timeSlot.location
    }
}

extension Array where Element == Subject {
    func exportToJSON() throws -> Data {
        let dtos = self.map(SubjectDTO.init)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(dtos)
    }
    
    static func importFromJSON(_ data: Data) throws -> [SubjectDTO] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([SubjectDTO].self, from: data)
    }
}
