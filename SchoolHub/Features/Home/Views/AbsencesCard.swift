//
//  AbsencesCard.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import SwiftUI
import Charts

struct AbsencesCard: View {
    let data: [(date: Date, value: Int)]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Image(systemName: "chart.bar.xaxis")
                    .fontWeight(.medium)
                    .foregroundStyle(.purple)
                Text("Absences Evolution")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.purple)
            }
            Chart(data + [(date: .now.advanced(by: -1 * 60 * 60 * 24 * 30), value: 0), (date: .now, value: 0)], id: \.date) {
                BarMark(
                    x: .value("Day", $0.date, unit: .day),
                    y: .value("Sales", $0.value)
                )
                .foregroundStyle(.purple)
            }
//            .chartXAxis(.hidden)
//                        .chartXAxis {
//                                            AxisMarks(values: .stride(by: .day)) { _ in
//                                                AxisTick()
//                                                AxisGridLine()
//                                                AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
//                AxisMarks(values: .stride(by: .day)) { _ in
//                    AxisTick()
//                    AxisGridLine()
//                    AxisValueLabel(format: .dateTime.month().day())
//                }
//            }
            .frame(height: 100)
        }
    }
}

//#Preview {
//    let viewModel = HomeViewModel()
//    AbsencesCard(data: viewModel.getAbsencesFromLast30Days())
//}
