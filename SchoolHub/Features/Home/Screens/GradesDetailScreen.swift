//
//  GradesDetailScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 29.10.2024.
//

import Charts
import SwiftData
import SwiftUI

struct AverageChart: View {
    @Binding var scrollPosition: Date
    @State var averageChangePoints: [(date: Date, value: Double)]
    @State private var rawSelectedDate: Date?

    func endOfDay(for date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: date)!
    }

    var selectedDate: Date? {
        if let rawSelectedDate {
            return averageChangePoints.first(where: {
                let endOfDay = endOfDay(for: $0.date)

                return ($0.date ... endOfDay).contains(rawSelectedDate)
            })?.date
        }

        return nil
    }

    var body: some View {
        Chart {
            ForEach(averageChangePoints, id: \.date) { element in
                LineMark(
                    x: .value("Day", element.date, unit: .day),
                    y: .value("Average", element.value)
                )
            }
            .symbol(Circle().strokeBorder(lineWidth: 3))
            .foregroundStyle(.blue)
            .interpolationMethod(.linear)
            .lineStyle(StrokeStyle(lineWidth: 3))
            .symbolSize(100)

            if let selectedDate {
                RuleMark(
                    x: .value("Selected", selectedDate, unit: .day)
                )
                .foregroundStyle(Color.gray.opacity(0.3))
                .offset(yStart: -10)
                //                .zIndex(-1)
                .annotation(
                    position: .top, spacing: 0,
                    overflowResolution: .init(
                        x: .fit(to: .chart),
                        y: .fit(to: .chart)
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text(
                            "\(averageChangePoints.first(where: { $0.date == selectedDate })?.value ?? 0, format: .number)"
                        )
                        .font(.title3.bold())

                        Text(selectedDate.formatted(.dateTime.month().day()))
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .padding(6)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(Color.gray.opacity(0.12))
                    }
                }
            }

            RuleMark(
                x: .value("Today", Date(), unit: .day)
            )
            .opacity(0)
        }
        .chartXAxis {
            AxisMarks(
                preset: .aligned,
                values: .stride(by: .month)
            ) { _ in
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.narrow))
            }
        }
        .chartYAxis(.visible)
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 3600 * 24 * 30 * 12)
        .chartScrollTargetBehavior(
            .valueAligned(
                matching: .init(hour: 0),
                majorAlignment: .matching(.init(day: 1))
            )
        )
        .chartScrollPosition(x: $scrollPosition)
        .chartXSelection(value: $rawSelectedDate)
    }
}

struct AverageByMonthChart: View {
    @State var data: [(month: Date, value: Double)]

    var body: some View {
        Chart(data, id: \.month) {
            BarMark(
                x: .value("Month", $0.month, unit: .month),
                y: .value("Average", $0.value)
            )
            .foregroundStyle(Color(.blue))

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

struct GradesCountByMonthChart: View {
    @State var data: [(month: Date, count: Int)]

    var body: some View {
        Chart(data, id: \.month) {
            BarMark(
                x: .value("Month", $0.month, unit: .month),
                y: .value("Grades", $0.count)
            )
            .foregroundStyle(Color(.blue))

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

struct AverageGradesByMonthChart: View {
    @State var data: [(month: Date, count: Int)]
    @State var average: Double

    var body: some View {
        Chart(data, id: \.month) {
            BarMark(
                x: .value("Month", $0.month, unit: .month),
                y: .value("Grades", $0.count)
            )
            .foregroundStyle(.gray.opacity(0.15))

            RuleMark(
                y: .value("Average", average)
            )
            .foregroundStyle(Color(.blue))
            .lineStyle(StrokeStyle(lineWidth: 3))
            .annotation(position: .top, alignment: .leading) {
                Text("Average grades per month: \(average, format: .number)")
                    .font(.body.bold())
                    .foregroundStyle(Color(.blue))
            }

            RuleMark(
                x: .value("Today", Date(), unit: .day)
            )
            .opacity(0)
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
    }
}

struct GradesCountEvolutionCard: View {
    @State var gradesThisMonth: Int
    @State var gradesLastMonth: Int

    @State var currentMonthIndex: Int
    @State var lastMonthIndex: Int

    var comparisonText: String {
        let difference = gradesThisMonth - gradesLastMonth

        switch difference {
        case 0:
            return "You have the same amount of grades as last month."
        case 1:
            return "You have 1 more grade this month compared to last month."
        case let x where x > 1:
            return
                "You have \(x) more grades this month compared to last month."
        case -1:
            return "You have 1 less grade this month compared to last month."
        default:
            return
                "You have \(abs(difference)) less grades this month compared to last month."
        }
    }

    var normalizedNumbers: (current: Double, previous: Double) {
        if gradesThisMonth == 0 && gradesLastMonth == 0 {
            return (0.02, 0.02)
        }

        let thisMonth =
            gradesThisMonth == 0
                ? Double(gradesLastMonth) * 0.02 : Double(gradesThisMonth)
        let lastMonth =
            gradesLastMonth == 0
                ? Double(gradesThisMonth) * 0.02 : Double(gradesLastMonth)

        if thisMonth >= lastMonth {
            return (1, lastMonth / thisMonth)
        } else {
            return (thisMonth / lastMonth, 1)
        }
    }

    var currentMonthName: String {
        Calendar.current
            .date(from: DateComponents(month: currentMonthIndex))?
            .formatted(.dateTime.month(.abbreviated)) ?? ""
    }

    var lastMonthName: String {
        Calendar.current
            .date(from: DateComponents(month: lastMonthIndex))?
            .formatted(.dateTime.month(.abbreviated)) ?? ""
    }

    var body: some View {
        Section {
            CardTemplate(
                systemName: "chart.xyaxis.line",
                title: "Grades",
                color: Color(.blue)
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(comparisonText)
                        .font(.headline)
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        (Text("\(gradesThisMonth)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            + Text(
                                " \(gradesThisMonth == 1 ? "grade" : "grades")"
                            )
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary))
                            .padding(.leading, 40)
                        HStack {
                            Text(
                                "\(Calendar.current.date(from: DateComponents(month: currentMonthIndex))?.formatted(.dateTime.month(.abbreviated)) ?? "")"
                            )
                            .font(.system(size: 16))
                            .frame(width: 32, alignment: .leading)
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(Color(.blue))
                                    .frame(
                                        width: geometry.size.width
                                            * normalizedNumbers.current,
                                        height: 24
                                    )
                            }
                        }
                        .frame(height: 24)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        (Text("\(gradesLastMonth)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            + Text(
                                " \(gradesLastMonth == 1 ? "grade" : "grades")"
                            )
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary))
                            .padding(.leading, 40)
                        HStack {
                            Text(
                                "\(Calendar.current.date(from: DateComponents(month: lastMonthIndex))?.formatted(.dateTime.month(.abbreviated)) ?? "")"
                            )
                            .frame(width: 32, alignment: .leading)
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(Color(.blue))
                                    .frame(
                                        width: geometry.size.width
                                            * normalizedNumbers.previous,
                                        height: 24
                                    )
                            }
                            .frame(height: 24)
                        }
                    }
                }
                .padding(.top, 2)
                .padding(.bottom, 6)
            }
        }
    }
}

struct GradesAverageEvolutionCard: View {
    @State var averageThisMonth: Double
    @State var averageLastMonth: Double

    @State var currentMonthIndex: Int
    @State var lastMonthIndex: Int

    var comparisonText: String {
        let difference = averageThisMonth - averageLastMonth

        switch difference {
        case 0:
            return "You have the same average this month as last month."
        case 1:
            return "You have 1 more point this month compared to last month."
        case let x where x > 1:
            return
                "You have \(x) more points this month compared to last month."
        case -1:
            return "You have 1 less point this month compared to last month."
        default:
            return
                "You have \(abs(difference)) less points this month compared to last month."
        }
    }

    var normalizedNumbers: (current: Double, previous: Double) {
        let current = averageThisMonth == 0 ? 0.02 : averageThisMonth / 10
        let previous = averageLastMonth == 0 ? 0.02 : averageLastMonth / 10

        return (current, previous)
    }

    var currentMonthName: String {
        Calendar.current
            .date(from: DateComponents(month: currentMonthIndex))?
            .formatted(.dateTime.month(.abbreviated)) ?? ""
    }

    var lastMonthName: String {
        Calendar.current
            .date(from: DateComponents(month: lastMonthIndex))?
            .formatted(.dateTime.month(.abbreviated)) ?? ""
    }

    var body: some View {
        Section {
            CardTemplate(
                systemName: "chart.xyaxis.line",
                title: "Grades",
                color: Color(.blue)
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(comparisonText)
                        .font(.headline)
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        Text(averageThisMonth == 0
                            ? "No grades"
                            : "\(String(format: "%.2f", averageThisMonth))")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.leading, 40)
                        HStack {
                            Text(
                                "\(Calendar.current.date(from: DateComponents(month: currentMonthIndex))?.formatted(.dateTime.month(.abbreviated)) ?? "")"
                            )
                            .font(.system(size: 16))
                            .frame(width: 32, alignment: .leading)
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(Color(.blue))
                                    .frame(
                                        width: geometry.size.width
                                            * normalizedNumbers.current,
                                        height: 24
                                    )
                            }
                        }
                        .frame(height: 24)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            averageLastMonth == 0
                                ? "No grades"
                                : "\(String(format: "%.2f", averageThisMonth))"
                        )
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.leading, 40)
                        HStack {
                            Text(
                                "\(Calendar.current.date(from: DateComponents(month: lastMonthIndex))?.formatted(.dateTime.month(.abbreviated)) ?? "")"
                            )
                            .frame(width: 32, alignment: .leading)
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(Color(.blue))
                                    .frame(
                                        width: geometry.size.width
                                            * normalizedNumbers.previous,
                                        height: 24
                                    )
                            }
                            .frame(height: 24)
                        }
                    }
                }
                .padding(.top, 2)
                .padding(.bottom, 6)
            }
        }
    }
}

struct GradesChartPicker: View {
    @Binding var chartType: GradesCharts

    var body: some View {
        Picker("Chart Type", selection: $chartType) {
            Text("Average").tag(GradesCharts.average)
            Text("Average per month").tag(GradesCharts.perMonthAverage)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

enum GradesCharts {
    case average
    case perMonthAverage
}

struct GradesDetailScreen: View {
    @Query private var grades: [Grade]

    @State private var chartType: GradesCharts = .average
    @ObservedObject private var viewModel: GradesDetailViewModel = .init()

    @State var scrollPositionStart: Date = .now.addingTimeInterval(
        -1 * 3600 * 24 * 30)

    @State private var currentMonthIndex: Int = Calendar.current.component(
        .month, from: .now
    )
    @State private var lastMonthIndex: Int = Calendar.current.component(
        .month,
        from: Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: Date.now
        )!
    )

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading) {
                        GradesChartPicker(chartType: $chartType)
                            .padding(.bottom)
                        VStack(alignment: .leading) {
                            Text("Overall Average")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Text(
                                viewModel
                                    .overallAverage(for: grades) == 0
                                    ? "No grades"
                                    : "\(viewModel.overallAverage(for: grades), format: .number)"
                            )
                            .font(.title2.bold())
                        }

                        if !(grades.isEmpty) {
                            switch chartType {
                            case .average:
                                AverageChart(
                                    scrollPosition: $scrollPositionStart,
                                    averageChangePoints:
                                    viewModel.getOverallAverageChangePoints(
                                        for: grades)
                                )
                                .frame(height: 240)
                            case .perMonthAverage:
                                AverageByMonthChart(
                                    data: viewModel.getOverallAverageByMonth(
                                        for: grades)
                                )
                                .frame(height: 240)
                            }
                        }
                    }
                }
                Section {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Grades Count")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Text(
                                "Total grades: \(grades.count)"
                            )
                            .font(.title2.bold())
                        }

                        if !(grades.isEmpty) {
                            GradesCountByMonthChart(
                                data: viewModel.getGradesCountByMonth(
                                    for: grades)
                            )
                            .frame(height: 240)
                        }
                    }
                }

                Section("Highlights") {
                    CardTemplate(
                        systemName: "chart.xyaxis.line",
                        title: "Grades",
                        color: .blue
                    ) {
                        AverageGradesByMonthChart(
                            data: viewModel.getGradesCountByMonth(for: grades),
                            average:
                            viewModel
                                .averageGradesByMonth(
                                    for: viewModel.getGradesCountByMonth(
                                        for: grades))
                        )
                        .frame(height: 100)
                    }
                }
                .headerProminence(.increased)

                GradesCountEvolutionCard(
                    gradesThisMonth:
                    viewModel
                        .gradesCount(
                            for: currentMonthIndex,
                            in: grades
                        ),
                    gradesLastMonth:
                    viewModel
                        .gradesCount(
                            for: lastMonthIndex,
                            in: grades
                        ),
                    currentMonthIndex: currentMonthIndex,
                    lastMonthIndex: lastMonthIndex
                )

                GradesAverageEvolutionCard(
                    averageThisMonth:
                    viewModel
                        .gradesAverage(
                            for: currentMonthIndex,
                            in: grades
                        ),
                    averageLastMonth:
                    viewModel
                        .gradesAverage(
                            for: lastMonthIndex,
                            in: grades
                        ),
                    currentMonthIndex: currentMonthIndex,
                    lastMonthIndex: lastMonthIndex
                )
            }
            .listSectionSpacing(10)
            .navigationTitle("Grades")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    GradesDetailScreen()
}

/// TODO
/// x per month average
/// x number of grades per month
/// x highlights average number of grades per month
/// - highlights average last month vs this month
/// x highllighs number of grades last month vs this month
/// - grades left to get this year
/// - grades left to reach a certain average
