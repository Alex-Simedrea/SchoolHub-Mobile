//
//  GradesDetailViewModel.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 29.10.2024.
//

import Foundation

class GradesDetailViewModel: ObservableObject {
    func estimatedOverallAverage(for subjects: [Subject]) -> Double {
        let shownSubjects = subjects.filter { !$0.hidden }
        
        let sum = shownSubjects.reduce(0) { $0 + Int(round($1.average ?? 10)) }
        let count = shownSubjects.count
        
        return count == 0 ? 0 : Double(sum) / Double(count)
    }
    
    func overallAverage(for grades: [Grade]) -> Double {
        let gradesBySubject = Dictionary(grouping: grades, by: { $0.subject })
        let averageBySubject = gradesBySubject.mapValues { grades in
            Double(grades.reduce(0) { $0 + $1.value }) / Double(grades.count)
        }
        let totalAverage = averageBySubject.values.reduce(0, +) / Double(averageBySubject.count)
        return averageBySubject.isEmpty ? 0 : totalAverage
    }
    
    func getOverallAverageChangePoints(for grades: [Grade]) -> [(date: Date, value: Double)] {
        let sortedGrades = grades.sorted { $0.date < $1.date }
        
        var previousAverage: Double?
        var gradesUpToDate: [Grade] = []
        
        var result: [(date: Date, value: Double)] = []

        for grade in sortedGrades {
            gradesUpToDate.append(grade)
            let currentAverage = overallAverage(for: gradesUpToDate)
            
            if previousAverage == nil || previousAverage != currentAverage {
                result.append((date: grade.date, value: currentAverage))
                previousAverage = currentAverage
            }
        }
        
        return result
    }
    
    func getOverallAverageByMonth(for grades: [Grade]) -> [(month: Date, value: Double)] {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        let startYear = currentMonth >= 9 ? currentYear : currentYear - 1
        
        let startDate = calendar.date(from: DateComponents(
            year: startYear,
            month: 9,
            day: 1
        ))!
        
        let currentMonthDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        
        let groupedByDate = Dictionary(grouping: grades) { grade in
            calendar.date(from: calendar.dateComponents([.year, .month], from: grade.date))!
        }
        
        var allMonths: [Date] = []
        var date = startDate
        while date <= currentMonthDate {
            allMonths.append(date)
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }
        
        let result = allMonths.map { month in
            (month: month, value: overallAverage(for: groupedByDate[month] ?? []))
        }
        .sorted { $0.month > $1.month }
        
        return result
    }
    
    func averageGradesByMonth(for months: [(month: Date, count: Int)]) -> Double {
        let totalGrades = months.reduce(0) { $0 + $1.count }
        
        return months.isEmpty ? 0 : Double(totalGrades) / Double(months.count)
    }
    
    func gradesAverage(for month: Int, in grades: [Grade]) -> Double {
        let gradesInMonth = grades.filter {
            Calendar.current.component(.month, from: $0.date) == month
        }
        
        return gradesInMonth.isEmpty ? 0 : overallAverage(for: gradesInMonth)
    }
    
    func gradesCount(for month: Int, in grades: [Grade]) -> Int {
        return grades.filter {
            Calendar.current.component(.month, from: $0.date) == month
        }.count
    }
    
    func getGradesCountByMonth(for grades: [Grade]) -> [(month: Date, count: Int)] {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        let startYear = currentMonth >= 9 ? currentYear : currentYear - 1
        
        let startDate = calendar.date(from: DateComponents(
            year: startYear,
            month: 9,
            day: 1
        ))!
        
        let currentMonthDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        
        let groupedByDate = Dictionary(grouping: grades) { grade in
            calendar.date(from: calendar.dateComponents([.year, .month], from: grade.date))!
        }
        
        var allMonths: [Date] = []
        var date = startDate
        while date <= currentMonthDate {
            allMonths.append(date)
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }
        
        let result = allMonths.map { month in
            (month: month, count: groupedByDate[month]?.count ?? 0)
        }
        .sorted { $0.month > $1.month }
        
        return result
    }
}
