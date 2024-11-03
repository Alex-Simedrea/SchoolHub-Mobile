//
//  SubjectScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 31.10.2024.
//

import SwiftData
import SwiftUI

struct StatCard: View {
    @State var symbolName: String
    @State var title: String
    @State var value: String
    @State var color: Color

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: symbolName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
                    .foregroundStyle(color)
                Spacer()
                Text(value)
                    .foregroundStyle(.primary)
                    .font(.title2.bold())
                    .lineSpacing(-2)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Text(title)
                .foregroundStyle(.primary.opacity(0.8))
                .font(.callout.bold())
                .lineSpacing(-2)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
//                .frame(height: height, alignment: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SubjectScreen: View {
    @State var subject: Subject
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State private var isTimeStampPickerPresented = false

    var body: some View {
//        ScrollView {
        ZStack(alignment: .top) {
            Circle()
                .blur(radius: 100)
                .frame(maxWidth: .infinity)
                .offset(y: -220)
                .foregroundStyle(subject.color.color.opacity(0.9))
            List {
                Section {
                    VStack(alignment: .center, spacing: 16) {
                        Circle()
                            .overlay(alignment: .center) {
                                Image(systemName: subject.symbolName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(subject.color.color)
                                    .padding(16)
                                    .fontWeight(.semibold)
                            }
                            .frame(width: 70)
                            .foregroundStyle(.white)
                        Text(subject.displayName)
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color(.clear))
//                        .padding(.top, 32)
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
                            title: "Grades count",
                            value: "\(subject.grades.count)/\(subject.timeSlots.count + 3)",
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
                Section("Timetable") {
                    ForEach(subject.timeSlots.sorted {
                        $0.isEarlier(than: $1)
                    }, id: \TimeSlot.id) { timeSlot in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(timeSlot.weekday.name)
                                Spacer()
                                Text(
                                    timeSlot.startTime
                                        .formatted(.dateTime.hour().minute())
                                )
                                Text("-")
                                Text(timeSlot.endTime.formatted(.dateTime.hour().minute()))
                            }
                            if let location = timeSlot.location, !location.isEmpty {
                                Text(location)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                context.delete(timeSlot)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    Button {
                        isTimeStampPickerPresented = true
                    } label: {
                        Label("Add time slot", systemImage: "plus")
                    }
                }
                .headerProminence(.increased)
            }
            .contentMargins(.top, 0, for: .scrollContent)
            .scrollContentBackground(.hidden)
        }
//        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(.gray.opacity(0.2))
                        .frame(width: 30, height: 30)

                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .contentShape(Circle())
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $isTimeStampPickerPresented) {
            AddTimeSlotScreen(subject: subject)
        }
    }
}

#Preview {
    SubjectScreen(
        subject: .init(
            name: "Matematica",
            grades: [],
            absences: [],
            color: .teal,
            symbolName: "x.squareroot"
        )
    )
}
