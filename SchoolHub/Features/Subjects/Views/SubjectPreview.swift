//
//  SubjectPreview.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 31.10.2024.
//

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

//#Preview {
//    SubjectPreview()
//}
