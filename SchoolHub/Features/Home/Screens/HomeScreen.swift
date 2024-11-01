//
//  HomeScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import SwiftData
import SwiftUI

struct HomeScreen: View {
    @Query var subjects: [Subject]
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: HomeViewModel = .init()
    @Namespace var namespace
    @Binding var selectedTab: Tabs

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Stats")) {
                    StatsCard(
                        title: "Grades Stats",
                        systemName: "chart.bar.fill",
                        color: Color(.blue),
                        values: [
                            String(
                                format: "%.2f",
                                viewModel
                                    .getOverallAverage(forSubjects: subjects)
                            ),
                            String(viewModel.getGradesCountThisWeek(forSubjects: subjects)),
                            String(viewModel.getGradesCountThisMonth(forSubjects: subjects)),
                        ],
                        labels: ["overall average", "this week", "this month"]
                    )
                    .padding(.vertical, 8)
                }
                .headerProminence(.increased)
                Section {
                    StatsCard(
                        title: "Absences Stats",
                        systemName: "calendar",
                        color: Color(.orange),
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
                        GradesCard(data: viewModel.getOverallAveragesFromLast30Days(forSubjects: subjects))
                    }
                }
                Section(header: Text("Recents")) {
                    ForEach(
                        viewModel.getRecentItems(fromSubjects: subjects),
                        id: \.id
                    ) { item in
                        switch item {
                        case .absence(let absence):
                            AbsenceGeneralListItem(
                                color: absence.subject?.color.color ?? .blue,
                                symbolName: absence.subject?.symbolName ?? "graduationcap.fill",
                                subjectName: absence.subject?.name ?? "",
                                excused: absence.excused,
                                date: absence.date
                            )
                        case .grade(let grade):
                            GradeGeneralListItem(
                                color: grade.subject?.color.color ?? .blue,
                                symbolName: grade.subject?.symbolName ?? "graduationcap.fill",
                                subjectName: grade.subject?.name ?? "",
                                date: grade.date,
                                value: grade.value
                            )
                        }
                    }
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Dashboard")
            .refreshable {
                Task { try await fetchAndSaveData() }
            }
            .listSectionSpacing(10)
        }
        .onAppear {
//            Task { try await fetchAndSaveData() }
        }
    }

    private func fetchAndSaveData() async throws {
        let fetchedSubjects = try await viewModel.getData()

        for fetchedSubject in fetchedSubjects {
            let fetchedSubjectName: String = fetchedSubject.name

            let descriptor = FetchDescriptor<Subject>(
                predicate: #Predicate<Subject> {
                    $0.name == fetchedSubjectName
                }
            )

            if let subject = try context.fetch(descriptor).first {
                for grade in subject.grades {
                    context.delete(grade)
                }
                for absence in subject.absences {
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
