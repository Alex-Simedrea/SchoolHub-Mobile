//
//  Extensions.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 25.10.2024.
//

import Foundation

extension Date {
    func formattedRelative() -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            return formatter.string(from: self)
        }
    }
    
    func isTimeEarlier(than other: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.hour, .minute], from: self)
        let components2 = calendar.dateComponents([.hour, .minute], from: other)
        
        let minutes1 = (components1.hour ?? 0) * 60 + (components1.minute ?? 0)
        let minutes2 = (components2.hour ?? 0) * 60 + (components2.minute ?? 0)
        
        return minutes1 < minutes2
    }
    
    var weekDay: Weekday {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: self)
        let adjustedWeekday = weekdayNumber == 1 ? 7 : weekdayNumber - 1
        return Weekday(rawValue: adjustedWeekday) ?? .monday
    }
}
