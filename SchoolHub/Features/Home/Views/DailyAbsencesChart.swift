//
//  DailyAbsencesChart.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 29.10.2024.
//

import SwiftUI
import Charts

struct DailyAbsencesChart: View {
    @Binding var scrollPosition: Date
    @State var absences: [(date: Date, count: Int)]
    
    var body: some View {
        Chart {
            ForEach(absences, id: \.date) {
                BarMark(
                    x: .value("Day", $0.date, unit: .day),
                    y: .value("Count", $0.count)
                )
            }
            .foregroundStyle(Color(.orange))
            
            RuleMark(
                x: .value("Today", Date(), unit: .day)
            )
            .opacity(0)
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 3600 * 24 * 30)
        .chartScrollTargetBehavior(
            .valueAligned(
                matching: .init(hour: 0),
                majorAlignment: .matching(.init(day: 1))
            ))
        .chartScrollPosition(x: $scrollPosition)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
    }
}

//#Preview {
//    DailyAbsencesChart()
//}
