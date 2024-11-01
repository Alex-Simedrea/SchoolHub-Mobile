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
}
