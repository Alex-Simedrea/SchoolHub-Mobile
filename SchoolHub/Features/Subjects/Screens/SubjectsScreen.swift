//
//  SubjectsScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 30.10.2024.
//

import SwiftData
import SwiftUI

struct SubjectPreview: View {
    @State var subject: Subject

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(alignment: .center, spacing: 16) {
                        Image(systemName: subject.symbolName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32)
                            .foregroundStyle(subject.color.color)
                            //                    .padding(12)
                            .fontWeight(.semibold)
                        Text(subject.displayName)
                            .font(.title.bold())
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color(.clear))
                }
                //                        .padding(.top, 32)

                Section {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ]) {
                        StatCard(
                            symbolName: "chart.bar.xaxis",
                            title: "Average",
                            value: subject.grades.average == 0
                                ? "N/A"
                                : subject.grades.average.gradeFormatted,
                            color: subject.color.color
                        )
                        StatCard(
                            symbolName: "number",
                            title: "Grades",
                            value: String(subject.grades.count),
                            color: subject.color.color
                        )
                        StatCard(
                            symbolName: "calendar.badge.checkmark",
                            title: "Excused",
                            value: String(subject.absences.excusedCount),
                            color: subject.color.color
                        )
                        StatCard(
                            symbolName: "calendar.badge.minus",
                            title: "Unexcused",
                            value: String(subject.absences.unexcusedCount),
                            color: subject.color.color
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color(.clear))
                    .listRowInsets(.init())
                }

                Section("Grades") {
                    if subject.grades.isEmpty {
                        Text("No grades")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    ForEach(
                        subject.grades.sorted { $0.date > $1.date },
                        id: \.id
                    ) { grade in
                        HStack {
                            Text(String(grade.value))
                                .font(.title3)
                                .fontWeight(.medium)
                            Spacer()
                            Text(grade.date.formattedRelative())
                                .font(.body)
                        }
                    }
                }
                .headerProminence(.increased)

                Section("Absences") {
                    if subject.absences.isEmpty {
                        Text("No absences")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    ForEach(
                        subject.absences.sorted { $0.date > $1.date },
                        id: \.id
                    ) { absence in
                        HStack {
                            HStack {
                                if absence.excused {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Excused")
                                        .font(.body)
                                        .fontWeight(.medium)
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                    Text("Not excused")
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                            }
                            Spacer()
                            Text(absence.date.formattedRelative())
                                .font(.body)
                        }
                    }
                }
                .headerProminence(.increased)
                //            .listRowBackground(Color(.clear))
                //            .listRowInsets(.init())
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct SubjectCard: View {
    @State var subject: Subject
    @State private var height: CGFloat = UIFont.preferredFont(forTextStyle: .body).lineHeight * 2

    func average() -> Double {
        return subject.grades.isEmpty ? 0 : subject.grades.reduce(0) {
            $0 + Double($1.value)
        } / Double(subject.grades.count)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: subject.symbolName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
                    .foregroundStyle(.white)

                Spacer()
                Menu {
                    Button(action: {}) {
                        Label("Edit subject", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: {}) {
                        Label("Hide subject", systemImage: "eye.slash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .fontWeight(.semibold)
                        .padding(6)
                        .foregroundStyle(.white)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            Spacer()
            Text(subject.displayName)
                .foregroundStyle(.white)
                .font(.body.bold())
                .lineSpacing(-2)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: height, alignment: .bottom)

            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "chart.bar.xaxis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12)
//                        .foregroundStyle(.white)
                    Text("\(average(), format: .number)")
//                        .foregroundStyle(.white)
                        .font(.caption.bold())
                }
                .foregroundStyle(.white.opacity(0.8))
                HStack(spacing: 3) {
                    Image(systemName: "number")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12)
//                        .foregroundStyle(.white)
                    Text("\(subject.grades.count)")
//                        .foregroundStyle(.white)
                        .font(.caption.bold())
                }
                .foregroundStyle(.white.opacity(0.8))
                HStack(spacing: 3) {
                    Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12)
//                        .foregroundStyle(.white)
                    Text("\(subject.absences.count)")
//                        .foregroundStyle(.white)
                        .font(.caption.bold())
                }
                .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .background(subject.color.color.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contextMenu {
            Button(action: {}) {
                Label("Edit subject", systemImage: "pencil")
            }
            Button(role: .destructive, action: {}) {
                Label("Hide subject", systemImage: "eye.slash")
            }
        } preview: {
            SubjectPreview(subject: subject)
        }
    }
}

struct SubjectsScreen: View {
    @Query(sort: \Subject.displayName) private var subjects: [Subject]
    @Namespace private var namespace

    let items = Array(1 ... 10)

    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(subjects, id: \.id) { item in
                        NavigationLink(
                            destination: SubjectScreen(subject: item)
                                .navigationTransition(
                                    .zoom(sourceID: item.id, in: namespace)
                                )
                        ) {
                            SubjectCard(subject: item)
                        }
                        .matchedTransitionSource(id: item.id, in: namespace)
                    }
                }
                .padding()
            }
            .navigationTitle("Subjects")
        }
    }
}

#Preview {
    SubjectsScreen()
}
