//
//  TimeSlot.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 01.11.2024.
//

import Foundation
import SwiftData

@Model
class TimeSlot {
    @Attribute(.unique) var id = UUID()
    var weekday: Weekday
    var startTime: Date
    var endTime: Date
    var location: String?
    @Relationship(inverse: \Subject.timeSlots) var subject: Subject?

    init(
        id: UUID = UUID(),
        weekday: Weekday,
        startTime: Date,
        endTime: Date,
        location: String? = nil
    ) {
        self.id = id
        self.weekday = weekday
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
    }
}

extension TimeSlot {
    func isEarlier(than other: TimeSlot) -> Bool {
        if self.weekday == other.weekday {
            return self.startTime.isTimeEarlier(than: other.startTime)
        }
        return self.weekday.id < other.weekday.id
    }
}
