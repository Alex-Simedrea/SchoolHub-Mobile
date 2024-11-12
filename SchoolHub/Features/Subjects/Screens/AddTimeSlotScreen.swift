//
//  AddTimeSlotScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 01.11.2024.
//

import SwiftUI
import WidgetKit

struct AddTimeSlotScreen: View {
    @State var subject: Subject
    @State private var weekday: Weekday = .monday
    @State private var startTime = Calendar.current
        .date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
    @State private var endTime = Calendar.current
        .date(bySettingHour: 8, minute: 50, second: 0, of: .now) ?? .now
    @State private var location: String = ""

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            TimeSlotPicker(
                weekday: $weekday,
                startTime: $startTime,
                endTime: $endTime,
                location: $location
            )
            .navigationTitle("Add Time Slot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        subject.timeSlots?
                            .append(
                                .init(
                                    weekday: weekday,
                                    startTime: startTime,
                                    endTime: endTime,
                                    location: location.isEmpty ? nil : location
                                )
                            )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddTimeSlotScreen(subject: .init(name: "Math", grades: [], absences: []))
}
