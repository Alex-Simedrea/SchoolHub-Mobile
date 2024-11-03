//
//  MonthlyAbsencesChart.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 29.10.2024.
//

import SwiftUI
import Charts

struct MonthlyAbsencesChart: View {
    @State var absences: [(month: Date, count: Int)]
    
    var body: some View {
        Chart(absences, id: \.month) {
            BarMark(
                x: .value("Month", $0.month, unit: .month),
                y: .value("Sales", $0.count)
            )
            .foregroundStyle(Color(.tangerine))
            
            RuleMark(
                x: .value("Today", Date(), unit: .day)
            )
            .opacity(0)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
    }
}

//#Preview {
//    MonthlyAbsencesChart()
//}
