//
//  RootScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import SwiftData
import SwiftUI

enum Tabs: Hashable {
    case dashboard
    case subjects
    case subject(Subject)
    case timetable
    case calculator
    case settings
}

struct RootScreen: View {
    @State var selectedTab: Tabs = .dashboard
    @EnvironmentObject var auth: Auth
    @Query private var subjects: [Subject]
    @State private var isShowingSheet = false
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "house", value: .dashboard) {
                HomeScreen(selectedTab: $selectedTab)
            }
            if ProcessInfo.processInfo.isOnMac {
                TabSection("Subjects") {
                    let sortedSubjects: [Subject] = subjects
                        .sorted { $0.displayName < $1.displayName }
                        .filter { !$0.hidden }
                    ForEach(sortedSubjects) { subject in
                        Tab(
                            subject.displayName,
                            systemImage: subject.symbolName
                                .replacingOccurrences(of: ".fill", with: ""),
                            value: Tabs.subject(subject)
                        ) {
                            SubjectScreen(subject: subject)
                                .sheet(isPresented: $isShowingSheet) {
                                    SubjectEditScreen(subject: subject)
                                }
                        }
                        .contextMenu {
                            Button(action: {
                                selectedTab = .subject(subject)
                                isShowingSheet = true
                            }) {
                                Label("Edit subject", systemImage: "pencil")
                            }
                            if !subject.hidden {
                                Button(role: .destructive, action: {
                                    subject.hidden = true
                                }) {
                                    Label("Hide subject", systemImage: "eye.slash")
                                }
                            }
                            if subject.hidden {
                                Button(action: {
                                    subject.hidden = false
                                }) {
                                    Label("Unhide subject", systemImage: "eye")
                                }
                            }
                        }
                    }
                }
            } else {
                Tab("Subjects", systemImage: "book", value: .subjects) {
                    SubjectsScreen()
                }
            }
            Tab("Timetable", systemImage: "calendar", value: .timetable) {
                TimetableScreen()
            }
            Tab("Calculator", systemImage: "number", value: .calculator) {
                AveragesScreen()
            }
            Tab("Settings", systemImage: "gear", value: .settings) {
                SettingsScreen()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onChange(of: subjects) {
            let groupedSubjects = Dictionary(grouping: subjects, by: \.name)
            let deduplicatedSubjects = groupedSubjects.map { $0.value.first! }
            let subjectsToDelete = subjects.filter { !deduplicatedSubjects.contains($0) }
            for subject in subjectsToDelete {
                context.delete(subject)
            }
        }
    }
}

#Preview {
    RootScreen()
        .environmentObject(Auth.shared)
}
