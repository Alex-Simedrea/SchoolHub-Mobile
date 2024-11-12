//
//  ContentView.swift
//  SchoolHubWatch Watch App
//
//  Created by Alexandru Simedrea on 10.11.2024.
//

import SwiftData
import SwiftUI

struct DayView: View {
    @Query private var subjects: [Subject]
    @Query private var timeSlots: [TimeSlot]
    @State var currentDay: Int

    var body: some View {
        NavigationStack {
            List {
                ForEach(timeSlots
                    .filter { $0.weekday.rawValue == currentDay }
                    .sorted { $0.isEarlier(than: $1) },
                    id: \.id)
                { timeSlot in
                    HStack {
                        VStack(alignment: .leading) {
                            if let subject = timeSlot.subject {
                                Text(subject.displayName)
                                    .font(.callout.bold())
                                    .foregroundStyle(.white)
                            }
                            if let location = timeSlot.location, !location.isEmpty {
                                Text(location)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(timeSlot.startTime.formatted(.dateTime.hour().minute()))
                                .font(.footnote)
                                .foregroundStyle(.white)
                            Text(timeSlot.endTime.formatted(.dateTime.hour().minute()))
                                .font(.footnote)
                                .foregroundStyle(.white)
                        }
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(timeSlot.subject?.color.color ?? Color.blue)
                    )
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(0)
            .navigationTitle("\(Weekday(rawValue: currentDay)?.name ?? "")")
        }
    }
}

struct TimetableScreen: View {
    @Query private var subjects: [Subject]
    @Query private var timeSlots: [TimeSlot]
    @State private var tabSelection: Int = 1

    var currentDay: Int {
        let day = Date.now.weekDay.rawValue
        if day > 5 {
            return 1
        }
        return day
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $tabSelection) {
                ForEach(1 ... 5, id: \.self) { day in
                    DayView(currentDay: day)
                        .tag(day)
                }
            }
            .onAppear {
                tabSelection = currentDay
            }
        }
    }
}

struct AbsenceCard: View {
    let color: Color
    let symbolName: String
    let subjectName: String
    let excused: Bool
    let date: Date

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Absence".uppercased())
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                Text(subjectName)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(date.formattedRelative())
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                HStack(spacing: 4) {
                    if excused {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

struct GradeCard: View {
    let color: Color
    let symbolName: String
    let subjectName: String
    let date: Date
    let value: Int

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Grade".uppercased())
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                Text(subjectName)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(date.formattedRelative())
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                Text(String(value))
                    .font(.title3)
                    .fontWeight(.medium)
            }
        }
    }
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

struct RecentsScreen: View {
    @Query private var subjects: [Subject]

    var recentItems: [RecentItem] {
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
//                .prefix(20)
        )
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(
                    recentItems,
                    id: \.id
                ) { item in
                    switch item {
                    case .absence(let absence):
                        AbsenceCard(
                            color: absence.subject?.color.color ?? .blue,
                            symbolName: absence.subject?.symbolName ?? "graduationcap.fill",
                            subjectName: absence.subject?.displayName ?? "",
                            excused: absence.excused,
                            date: absence.date
                        )
                    case .grade(let grade):
                        GradeCard(
                            color: grade.subject?.color.color ?? .blue,
                            symbolName: grade.subject?.symbolName ?? "graduationcap.fill",
                            subjectName: grade.subject?.displayName ?? "",
                            date: grade.date,
                            value: grade.value
                        )
                    }
                }
            }
            .navigationTitle("Recents")
        }
    }
}

enum Screens: String, Hashable, CaseIterable, View {
    case recents = "Recents"
    case timetable = "Timetable"

    var icon: String {
        switch self {
        case .recents:
            return "clock.arrow.trianglehead.counterclockwise.rotate.90"
        case .timetable:
            return "calendar"
        }
    }

    var body: some View {
        switch self {
        case .recents:
            RecentsScreen()
        case .timetable:
            TimetableScreen()
        }
    }
}

struct ContentView: View {
    @State private var tabSelection: Int = 1
    @State private var splitSelection: Screens? = .timetable

    var body: some View {
        NavigationSplitView {
            List(selection: $splitSelection) {
                ForEach(Screens.allCases, id: \.self) { screen in
                    NavigationLink(destination: screen) {
                        Label(screen.rawValue, systemImage: screen.icon)
                    }
                }
            }
            .navigationTitle("SchoolHub")
        } detail: {
            splitSelection
        }
    }
}

#Preview {
    ContentView()
}
