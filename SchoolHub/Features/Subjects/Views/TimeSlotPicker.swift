//
//  TimeSlotPicker.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 01.11.2024.
//

import SwiftUI

struct TimeSlotPicker: View {
    @Binding var weekday: Weekday
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Binding var location: String

    var body: some View {
        Form {
            Picker(
                "Weekday",
                selection: $weekday as Binding<Weekday>
            ) {
                ForEach(Weekday.weekdays, id: \.id) { weekday in
                    Text(weekday.name).tag(weekday)
                }
            }
            DatePicker(
                "Start time",
                selection: $startTime,
                displayedComponents: [.hourAndMinute]
            )
            DatePicker(
                "End time",
                selection: $endTime,
                in: startTime...,
                displayedComponents: [.hourAndMinute]
            )
            TextField("Location", text: $location)
        }
    }
}

#Preview {
    TimeSlotPicker(
        weekday: .constant(.monday),
        startTime: .constant(Date()),
        endTime: .constant(Date()),
        location: .constant("Room 101")
    )
}
