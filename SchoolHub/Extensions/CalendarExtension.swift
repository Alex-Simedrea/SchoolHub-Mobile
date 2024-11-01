//
//  DateUtils.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 20.10.2024.
//

import Foundation

extension Calendar {
    func isDateBetweenThisMondayAndNow(date: Date) -> Bool {
        let startOfWeek = self.date(from: self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now))!
        return date >= startOfWeek && date <= .now
    }
    
    func isDateBetweenStartOfMonthAndNow(date: Date) -> Bool {
        let startOfMonth = self.date(from: self.dateComponents([.year, .month], from: .now))!
        return date >= startOfMonth && date <= .now
    }
    
    func isDateInCurrentSchoolYear(date: Date) -> Bool {
        var startDate: Date?
        var endDate: Date?
        
        if self.dateComponents([.month], from: .now).month ?? 0 >= 9 {
            startDate = self.date(from: DateComponents(year: self.component(.year, from: Date()), month: 9))
            endDate = self.date(from: DateComponents(year: self.component(.year, from: Date()) + 1, month: 7))
        } else {
            startDate = self.date(from: DateComponents(year: self.component(.year, from: Date()) - 1, month: 9))
            endDate = self.date(from: DateComponents(year: self.component(.year, from: Date()), month: 7))
        }
        
        return date >= startDate ?? Date() && date <= endDate ?? Date()
    }
    
    func convertToDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let dateWithoutYear = dateFormatter.date(from: dateString) else { return nil }
        
        let currentYear = self.component(.year, from: Date())
        let currentMonth = self.component(.month, from: Date())
        
        let month = self.component(.month, from: dateWithoutYear)
        let yearToUse = (month >= 9 && currentMonth < 9) ? currentYear - 1 : currentYear
        
        return self
            .date(
                from: DateComponents(
                    year: yearToUse,
                    month: month,
                    day: self.component(.day, from: dateWithoutYear)
                )
            )
    }
    
    func firstAndLastDayOfThisMonth() -> (first: Date, last: Date, month: Int) {
        let currentFirstDay = self.date(from: self.dateComponents([.year, .month], from: .now))!
        let currentLastDay = self.date(byAdding: DateComponents(month: 1, day: -1), to: currentFirstDay)!
        
        return (first: currentFirstDay, last: currentLastDay, month: self.component(.month, from: .now))
    }
    
    func firstAndLastDayOfLastMonth() -> (first: Date, last: Date, month: Int) {
        let currentFirstDay = self.date(from: self.dateComponents([.year, .month], from: .now))!
        
        let lastMonthFirstDay = self.date(byAdding: DateComponents(month: -1), to: currentFirstDay)!
        let lastMonthLastDay = self.date(byAdding: DateComponents(day: -1), to: currentFirstDay)!
        
        return (
            first: lastMonthFirstDay,
            last: lastMonthLastDay,
            month: self.component(.month, from: lastMonthFirstDay)
        )
    }
    
    func firstAndLastDay(forMonth month: Int) -> (first: Date, last: Date)? {
        guard (1...12).contains(month) else { return nil }
        
        let year = self.component(.year, from: .now)
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let firstDay = self.date(from: components) else { return nil }
        
        guard let lastDay = self.date(byAdding: DateComponents(month: 1, day: -1), to: firstDay) else { return nil }
        
        return (first: firstDay, last: lastDay)
    }
}
