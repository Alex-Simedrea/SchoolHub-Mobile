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
//    var id = UUID()
    var weekday: Weekday = Weekday.monday
    var startTime: Date = Date.now
    var endTime: Date = Date.now
    var location: String?
    @Relationship(inverse: \Subject.timeSlots) var subject: Subject?

    init(
        //        id: UUID = UUID(),
        weekday: Weekday,
        startTime: Date,
        endTime: Date,
        location: String? = nil
    ) {
//        self.id = id
        self.weekday = weekday
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
    }
}

extension TimeSlot {
    func isEarlier(than other: TimeSlot) -> Bool {
        if weekday == other.weekday {
            return startTime.isTimeEarlier(than: other.startTime)
        }
        return weekday.id < other.weekday.id
    }
    
    var nextOccurrence: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date.now
        let currentWeekDay = now.weekDay
        
        let startTimeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        var nextDate = calendar.startOfDay(for: now)
        
        if weekday.rawValue < currentWeekDay.rawValue {
            let daysToAdd = 7 - (currentWeekDay.rawValue - weekday.rawValue)
            nextDate = calendar.date(byAdding: .day, value: daysToAdd, to: nextDate) ?? nextDate
        } else if weekday == currentWeekDay, calendar.minutesSinceMidnight(for: now) >= calendar.minutesSinceMidnight(for: endTime) {
            nextDate = calendar.date(byAdding: .day, value: 7, to: nextDate) ?? nextDate
        } else {
            let daysToAdd = weekday.rawValue - currentWeekDay.rawValue
            nextDate = calendar.date(byAdding: .day, value: daysToAdd, to: nextDate) ?? nextDate
        }
        
        let nextStart = calendar.date(bySettingHour: startTimeComponents.hour ?? 0,
                                      minute: startTimeComponents.minute ?? 0,
                                      second: 0,
                                      of: nextDate) ?? nextDate
        
        let nextEnd = calendar.date(bySettingHour: endTimeComponents.hour ?? 0,
                                    minute: endTimeComponents.minute ?? 0,
                                    second: 0,
                                    of: nextDate) ?? nextDate
        
        return (nextStart, nextEnd)
    }
}

extension [TimeSlot] {
    var currentOrNextTimeSlot: TimeSlot? {
        guard !isEmpty else { return nil }
        
        let sortedSlots: [TimeSlot] = self.sorted { slot1, slot2 in
            if slot1.weekday == slot2.weekday {
                return slot1.startTime.isTimeEarlier(than: slot2.startTime)
            }
            return slot1.weekday.rawValue < slot2.weekday.rawValue
        }
        
        let now = Date.now
        let currentWeekDay = now.weekDay
        let calendar = Calendar.current
        let currentMinutes = calendar.minutesSinceMidnight(for: now)
        
        if let currentSlot = sortedSlots.first(where: { slot in
            slot.weekday == currentWeekDay &&
                calendar.minutesSinceMidnight(for: slot.startTime) <= currentMinutes &&
                calendar.minutesSinceMidnight(for: slot.endTime) > currentMinutes
        }) {
            return currentSlot
        }
        
        if let nextSlot = sortedSlots.first(where: { slot in
            if slot.weekday.rawValue > currentWeekDay.rawValue {
                return true
            }
            if slot.weekday == currentWeekDay {
                return calendar.minutesSinceMidnight(for: slot.startTime) >= currentMinutes
            }
            return false
        }) {
            return nextSlot
        }
        
        return sortedSlots.first
    }
}

extension [TimeSlot]? {
    var count: Int {
        return self?.count ?? 0
    }
}
