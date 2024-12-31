//
//  HomeScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

#if canImport(ActivityKit)
import ActivityKit
#endif
import SwiftData
import SwiftUI

struct HomeScreen: View {
    @Query var subjects: [Subject]
    @Query var grades: [Grade]
    @Query var absences: [Absence]
    @Query private var timeSlots: [TimeSlot]
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: HomeViewModel = .init()
    @Namespace var namespace
    @Binding var selectedTab: Tabs
    @State private var firstAppear = true

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Stats")) {
                    StatsCard(
                        title: "Grades Stats",
                        systemName: "chart.bar.fill",
                        color: Color(.blue),
                        values: [
                            viewModel.getOverallAverage(forSubjects: subjects).gradeFormatted,
                            String(viewModel.getGradesCountThisWeek(forSubjects: subjects)),
                            String(viewModel.getGradesCountThisMonth(forSubjects: subjects)),
                        ],
                        labels: ["average", "this week", "this month"]
                    )
                    .padding(.vertical, 8)
                }
                .headerProminence(.increased)
                Section {
                    StatsCard(
                        title: "Absences Stats",
                        systemName: "calendar",
                        color: Color(.tangerine),
                        values: [
                            String(viewModel.getAbsencesCountThisWeek(forSubjects: subjects)),
                            String(viewModel.getAbsencesCountThisMonth(forSubjects: subjects)),
                            String(viewModel.getAbsencesCountThisSchoolYear(forSubjects: subjects)),
                        ],
                        labels: ["this week", "this month", "this year"]
                    )
                    .padding(.vertical, 8)
                }
                Section(header: Text("Evolution")) {
                    NavigationLink(destination: AbsencesDetailScreen()) {
                        AbsencesCard(data: viewModel.getAbsencesFromLast30Days(forSubjects: subjects))
                    }
                }
                .headerProminence(.increased)
                Section {
                    NavigationLink(destination: GradesDetailScreen()) {
                        GradesCard(
                            data: viewModel
                                .getOverallAveragesFromLast30Days(
                                    for: viewModel
                                        .getGradesFromSubjects(subjects))
                        )
                    }
                }
                Section(header: Text("Recents")) {
                    ForEach(
                        viewModel.getRecentItems(fromSubjects: subjects, limit: 7),
                        id: \.id
                    ) { item in
                        switch item {
                        case .absence(let absence):
                            AbsenceGeneralListItem(
                                color: absence.subject?.color.color ?? .blue,
                                symbolName: absence.subject?.symbolName ?? "graduationcap.fill",
                                subjectName: absence.subject?.displayName ?? "",
                                excused: absence.excused,
                                date: absence.date
                            )
                        case .grade(let grade):
                            GradeGeneralListItem(
                                color: grade.subject?.color.color ?? .blue,
                                symbolName: grade.subject?.symbolName ?? "graduationcap.fill",
                                subjectName: grade.subject?.displayName ?? "",
                                date: grade.date,
                                value: grade.value
                            )
                        }
                    }
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                if ProcessInfo.processInfo.isOnMac {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            Task { try await fetchAndSaveData() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(.foreground)
                        }
                    }
                }
            }
            .refreshable {
                print("Refreshing")
                Task { try await fetchAndSaveData() }
            }
            .listSectionSpacing(10)
        }
        .onAppear {
            if firstAppear {
                Task { try await fetchAndSaveData() }
                firstAppear = false
            }
        }
    }

    private func fetchAndSaveData() async throws {
        if !Auth.shared.loggedIn {
            return
        }

        let fetchedSubjects = try await viewModel.getData()

        for grade in grades {
            context.delete(grade)
        }

        for absence in absences {
            context.delete(absence)
        }

        let groupedSubjects = Dictionary(grouping: subjects, by: \.name)
        let deduplicatedSubjects = groupedSubjects.map { $0.value.first! }
        let subjectsToDelete = subjects.filter { !deduplicatedSubjects.contains($0) }
        for subject in subjectsToDelete {
            context.delete(subject)
        }

        for fetchedSubject in fetchedSubjects {
            let fetchedSubjectName: String = fetchedSubject.name

            let descriptor = FetchDescriptor<Subject>(
                predicate: #Predicate<Subject> {
                    $0.name == fetchedSubjectName
                }
            )

            if let subject = try context.fetch(descriptor).first {
                for grade in subject.unwrappedGrades {
                    context.delete(grade)
                }

                for absence in subject.unwrappedAbsences {
                    context.delete(absence)
                }

                subject.grades = fetchedSubject.grades
                subject.absences = fetchedSubject.absences
            } else {
                context.insert(fetchedSubject)
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: Tabs = .dashboard
    HomeScreen(selectedTab: $selectedTab)
        .modelContainer(for: [Subject.self])
}
