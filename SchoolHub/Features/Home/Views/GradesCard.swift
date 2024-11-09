//
//  GradesCard.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 14.10.2024.
//

import Charts
import SwiftUI

struct GradesCard: View {
    let data: [(date: Date, value: Double)]

    let symbolSize: CGFloat = 100
    let lineWidth: CGFloat = 3

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Image(systemName: "chart.xyaxis.line")
                    .fontWeight(.medium)
                    .foregroundStyle(.purple)
                Text("Grades Evolution")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.purple)
            }
            Chart {
//                ForEach(data) { series in
                ForEach(data, id: \.date) { element in
                    LineMark(
                        x: .value("Day", element.date, unit: .day),
                        y: .value("Sales", element.value)
                    )
                }
//                    .foregroundStyle(by: .value("City", series.city))
//                    .symbol(by: .value("City", series.city))
//                }
                .symbol(Circle().strokeBorder(lineWidth: lineWidth))
                .foregroundStyle(.purple)
                .interpolationMethod(.linear)
                .lineStyle(StrokeStyle(lineWidth: lineWidth))
                .symbolSize(symbolSize)

//                PointMark(
//                    x: .value("Day", LocationData.last30DaysBest.weekday, unit: .day),
//                    y: .value("Sales", LocationData.last30DaysBest.sales)
//                )
//                .foregroundStyle(.purple)
//                .symbolSize(symbolSize)
            }
//            .chartForegroundStyleScale([
//                "San Francisco": .purple,
//                "Cupertino": .green
//            ])
//            .chartSymbolScale([
//                "San Francisco": Circle().strokeBorder(lineWidth: lineWidth),
//                "Cupertino": Circle().strokeBorder(lineWidth: lineWidth)
//            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
//            .chartYAxis(.hidden)
            .chartYScale(range: .plotDimension(endPadding: 8))
//            .chartLegend(.hidden)
            .frame(height: 100)
        }
    }
}

//#Preview {
//    @ObservedObject var viewModel: HomeViewModel = .init()
//
//    GradesCard(data: viewModel.getOverallAveragesFromLast30Days())
//}
