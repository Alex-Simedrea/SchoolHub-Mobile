//
//  HomeViewModel.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import Alamofire
import Foundation
import SwiftData
import SwiftUI

class HomeViewModel: ObservableObject {
    private func getRequestUrl(loginUrl: String) -> String {
        return loginUrl
            .replacingOccurrences(of: "login.php", with: "elev.php")
    }
    
    func fetchData() async throws -> String {
        do {
            let loginResponse = try await AF.request(
                Auth.shared
                    .getCredentials().requestUrl?
                    .replacingOccurrences(of: "login", with: "elev") ?? "",
                method: .get
            ).serializingResponse(using: .data).value
            
            let loginResponseString = String(data: loginResponse, encoding: .utf8)!

            if !loginResponseString.contains("table") {
                let retryResponse = try await AF.request(
                    Auth.shared.getCredentials().requestUrl ?? "",
                    method: .post,
                    parameters: [
                        "txtUser": Auth.shared.getCredentials().username,
                        "txtPwd": Auth.shared.getCredentials().password
                    ],
                    encoder: URLEncodedFormParameterEncoder.default,
                    headers: [
                        "Content-Type": "application/x-www-form-urlencoded"
                    ]
                ).serializingData().value
                
                return String(data: retryResponse, encoding: .utf8)!
            } else {
                return loginResponseString
            }
        } catch {
            print("Error: \(error)")
            return ""
        }
    }
    
    func parseData(_ docoment: String) throws -> [Subject] {
        var result: [Subject] = []
        
        let regex1 = /<th name=['"]n\d+['"] id=['"]n\d+['"].*align=['"]center['"][^>]*>([^<]*)/
        let matches1 = docoment.matches(of: regex1)
        
        let _ = matches1.compactMap { match in
            result
                .append(
                    .init(
                        name: String(match.output.1)
                            .prefix(1)
                            .uppercased() +
                            String(match.output.1)
                            .lowercased().dropFirst(),
                        grades: [],
                        absences: []
                    )
                )
        }
        
//        print(String(describing: allMatches1))
        
        let regex2 = /<table class=['"]tbNoteAbs['"] border=['"]0['"] cellpadding=['"]0['"] cellspacing=['"]0['"]>([\s\S]*?)<\/table>*/
        let matches2 = docoment.matches(of: regex2)
        let _ = matches2.enumerated().compactMap { index, match in
//            print(allMatches1[index])
//            print(match)
            let regex3 = /<\s*td\s*class="ctdNoteddDate.*?"\s*align="left"\s*>.*?<\/td>/
            let matches3 = match.output.1.matches(of: regex3)
            
            var currentAbsences: [Absence] = []
            
            let _ = matches3.compactMap { match3 in
                var date: Date?, excused: Bool?
                
                let regex4 = /[\d.]+/
                if let match4 = match3.output.firstMatch(of: regex4) {
//                    print(match4.output)
                    date = Calendar.current
                        .convertToDate(from: String(match4.output)) ?? .now
                }
                
                let regex5 = /cAbsMot/
                if let _ = match3.output.firstMatch(of: regex5) {
//                    print("motivata")
                    excused = true
                } else {
//                    print("nemotivata")
                    excused = false
                }
                
                if let date = date, let excused = excused {
                    currentAbsences.append(.init(date: date, excused: excused))
                }
            }
            
            result[index].absences = currentAbsences
//            print()
        }
        
        let regex6 = /<table class=['"]tbNoteNote['"] border=['"]0['"] cellpadding=['"]0['"] cellspacing=['"]0['"]>([\s\S]*?)<\/table>*/
        let matches6 = docoment.matches(of: regex6)
        let _ = matches6.enumerated().compactMap { index, match in
//            print(allMatches1[index])
            let regex7 = /<tr class=['"]cNoteNonEdit['"]>(?:(?!<td class=['"]ctdNoteAddNote['"]>&nbsp;<\/td>)[\s\S])*?<\/tr>/
            let matches7 = match.output.1.matches(of: regex7)
            
            var currentGrades: [Grade] = []
            
            let _ = matches7.compactMap { match7 in
                var date: Date?, value: Int?
                
                let regex8 = /<td class=['"]ctdNoteddDate['"] align=['"]left['"]>\s*(.*?)\s*<\/td>/
                if let match8 = match7.output.firstMatch(of: regex8) {
                    date = Calendar.current.convertToDate(from: String(match8.output.1)) ?? .now
//                    print(match8.output.1)
                }
                
                let regex9 = /<td class=['"]ctdNoteAddNote['"]>\s*(.*?)\s*<\/td>/
                if let match9 = match7.output.firstMatch(of: regex9) {
                    value = Int(match9.output.1) ?? 0
//                    print(match9.output.1)
                }
                
                if let date = date, let value = value {
                    currentGrades.append(.init(value: value, date: date))
                }
            }
            
            result[index].grades = currentGrades
        }
        
        return result
    }
    
    func getData() async throws -> [Subject] {
        let task = Task<[Subject], Error> {
            let docoment = try await fetchData()
            let fetchedSubjects = try parseData(docoment)
            return fetchedSubjects
        }
        
        let subjects = try await task.value
        return subjects
    }
    
    func getGradesFromSubjects(_ subjects: [Subject]) -> [Grade] {
        return subjects.flatMap { $0.unwrappedGrades }
    }
    
    func getGradesCountThisWeek(forSubjects subjects: [Subject]) -> Int {
        return subjects
            .flatMap { $0.unwrappedGrades }
            .filter { Calendar.current.isDateBetweenThisMondayAndNow(date: $0.date) }
            .count
    }
    
    func getGradesCountThisMonth(forSubjects subjects: [Subject]) -> Int {
        return subjects
            .flatMap { $0.unwrappedGrades }
            .filter { Calendar.current.isDateBetweenStartOfMonthAndNow(date: $0.date) }
            .count
    }
    
    func getOverallAverage(forSubjects subjects: [Subject]) -> Double {
        let shownSubjects = subjects.filter { !$0.hidden }
        
        let sum = shownSubjects.reduce(0) { $0 + Int(round($1.average ?? 10)) }
        let count = shownSubjects.count
        
        return count == 0 ? 0 : Double(sum) / Double(count)
    }
    
    func getAbsencesCountThisWeek(forSubjects subjects: [Subject]) -> Int {
        return subjects
            .flatMap { $0.unwrappedAbsences }
            .filter { Calendar.current.isDateBetweenThisMondayAndNow(date: $0.date) }
            .count
    }
    
    func getAbsencesCountThisMonth(forSubjects subjects: [Subject]) -> Int {
        return subjects
            .flatMap { $0.unwrappedAbsences }
            .filter { Calendar.current.isDateBetweenStartOfMonthAndNow(date: $0.date) }
            .count
    }
    
    func getAbsencesCountThisSchoolYear(forSubjects subjects: [Subject]) -> Int {
        return subjects
            .flatMap { $0.unwrappedAbsences }
            .filter { Calendar.current.isDateInCurrentSchoolYear(date: $0.date) }
            .count
    }
    
    func getAbsencesFromLast30Days(forSubjects subjects: [Subject]) -> [(date: Date, value: Int)] {
        let calendar = Calendar.current
        let now = Date()
        let last30Days = calendar.date(byAdding: .day, value: -30, to: now)!
        
        let absencesInLast30Days = subjects
            .flatMap { $0.unwrappedAbsences }
            .filter { $0.date >= last30Days && $0.date <= now }
            .reduce(into: [Date: Int]()) { result, absence in
                let startOfDay = calendar.startOfDay(for: absence.date)
                result[startOfDay, default: 0] += 1
            }
        
        let sortedAbsences = absencesInLast30Days
            .map { (date: $0.key, value: $0.value) }
            .sorted { $0.date < $1.date }
        
        return sortedAbsences
    }
    
    func overallAverage(for grades: [Grade]) -> Double {
        let gradesBySubject = Dictionary(grouping: grades, by: { $0.subject })
//        print(gradesBySubject.mapValues { $0.map { $0.value } })
        let averageBySubject = gradesBySubject.mapValues { grades in
            Double(grades.reduce(0) { $0 + $1.value }) / Double(grades.count)
        }
        let totalAverage = averageBySubject.values.reduce(0, +) / Double(averageBySubject.count)
        return averageBySubject.isEmpty ? 0 : totalAverage
    }
    
    func getOverallAveragesFromLast30Days(for grades: [Grade]) -> [(date: Date, value: Double)] {
        let sortedGrades = grades
            .sorted { $0.date < $1.date }
            .filter {
                $0.date >= Calendar.current.date(byAdding: .day, value: -30, to: .now)!
            }
        
        var previousAverage: Double?
        var gradesUpToDate: [Grade] = grades
            .sorted { $0.date < $1.date }
            .filter {
                $0.date < Calendar.current.date(byAdding: .day, value: -30, to: .now)!
            }
        
        var result: [(date: Date, value: Double)] = []
        
        for grade in sortedGrades {
            gradesUpToDate.append(grade)
            let currentAverage = overallAverage(for: gradesUpToDate)
//            print(grade)
            
            if previousAverage == nil || previousAverage != currentAverage {
                result.append((date: grade.date, value: currentAverage))
                previousAverage = currentAverage
            }
        }
        
        return result
    }
    
    enum RecentItem {
        case grade(Grade)
        case absence(Absence)
        
        var id: UUID {
            switch self {
            case .grade: return UUID()
            case .absence: return UUID()
            }
        }
        
        var date: Date {
            switch self {
            case .grade(let grade): return grade.date
            case .absence(let absence): return absence.date
            }
        }
    }
    
    func getRecentItems(fromSubjects subjects: [Subject], limit: Int = 5) -> [RecentItem] {
        let grades = subjects
            .flatMap { $0.unwrappedGrades }
            .sorted { $0.date < $1.date }
        let absences = subjects
            .flatMap { $0.unwrappedAbsences }
            .sorted { $0.date < $1.date }

        let gradeItems = grades.map { RecentItem.grade($0) }
        let absenceItems = absences.map { RecentItem.absence($0) }
        
        return Array(
            (gradeItems + absenceItems)
                .sorted { item1, item2 in
                    if item1.date == item2.date {
                        switch (item1, item2) {
                        case (.grade, .absence): return true
                        case (.absence, .grade): return false
                        default: return true
                        }
                    }
                    return item1.date > item2.date
                }
                .prefix(limit)
        )
    }
}
