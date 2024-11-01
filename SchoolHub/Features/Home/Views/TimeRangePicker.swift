//
//  TimeRangePicker.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 27.10.2024.
//

import SwiftUI

struct TimeRangePicker: View {
    @Binding var value: TimeRange
    
    var body: some View {
        Picker(selection: $value.animation(.easeInOut), label: EmptyView()) {
            Text("30 Days").tag(TimeRange.last30Days)
            Text("12 Months").tag(TimeRange.last12Months)
        }
        .pickerStyle(.segmented)
    }
}
