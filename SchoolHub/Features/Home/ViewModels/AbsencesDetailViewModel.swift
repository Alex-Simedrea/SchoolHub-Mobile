//
//  AbsencesDetailViewModel.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 27.10.2024.
//

import Foundation
import SwiftData

class AbsencesDetailViewModel: ObservableObject {
    func getAbsencesCount(in dateRange: ClosedRange<Date>, for absences: [Absence]) -> Int {
        return absences.filter { dateRange.contains($0.date) }.count
    }

    func getAbsences(in dateRange: ClosedRange<Date>, for absences: [Absence]) -> [Absence] {
        return absences.filter { dateRange.contains($0.date) }
    }
    
    func getAbsencesCountByDay(for absences: [Absence]) -> [(date: Date, count: Int)] {
        let groupedByDate = Dictionary(grouping: absences) { absence in
            Calendar.current.startOfDay(for: absence.date)
        }
        
        let result = groupedByDate
            .map { (date: $0.key, count: $0.value.count) }
            .sorted { $0.date > $1.date }
        
        return result
    }
    
    func getAbsencesCountByMonth(for absences: [Absence]) -> [(month: Date, count: Int)] {
        let groupedByDate = Dictionary(grouping: absences) { absence in
            Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: absence.date))!
        }
        
        var result = groupedByDate
            .map { (month: $0.key, count: $0.value.count) }
            .sorted { $0.month > $1.month }
        
        if !(result.first?.month == Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: .now))!) {
            result += [(month: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: .now))!, count: 0)]
        }
        
        return result
    }
    
    func getAverageAbsencesByMonth(for absences: [Absence]) -> Double {
        let groupedByDate = Dictionary(grouping: absences) { absence in
            Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: absence.date))!
        }
        
        let result = groupedByDate
            .map { (month: $0.key, count: $0.value.count) }
        
        let totalAbsences = result.reduce(0) { $0 + $1.count }
       
        return result.isEmpty ? 0 : Double(totalAbsences) / Double(result.count)
    }
}
