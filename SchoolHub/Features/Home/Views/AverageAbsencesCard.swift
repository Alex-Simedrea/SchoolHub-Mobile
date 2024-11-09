//
//  AverageAbsencesCard.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 29.10.2024.
//

import Charts
import SwiftUI

struct AverageAbsencesCard: View {
    @State var absences: [(month: Date, count: Int)]
    @State var average: Double

    var body: some View {
        Section {
            CardTemplate(
                systemName: "calendar",
                title: "Absences",
                color: Color(.tangerine)
            ) {
                Chart {
                    ForEach(absences, id: \.month) {
                        BarMark(
                            x: .value("Month", $0.month, unit: .month),
                            y: .value("Sales", $0.count)
                        )
                    }
                    .foregroundStyle(.gray.opacity(0.15))
                    RuleMark(
                        y: .value("Average", average)
                    )
                    .foregroundStyle(Color(.tangerine))
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .annotation(position: .top, alignment: .leading) {
                        Text(
                            "Average per month: \(average.rounded(), format: .number)"
                        )
                        .font(.body.bold())
                        .foregroundStyle(Color(.tangerine))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        //                        AxisGridLine()
                        //                        AxisTick()
                        AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
                    }
                }
                .chartYAxis(.hidden)
                .frame(height: 120)
            }
        }
    }
}

// #Preview {
//    AverageAbsencesCard()
// }
