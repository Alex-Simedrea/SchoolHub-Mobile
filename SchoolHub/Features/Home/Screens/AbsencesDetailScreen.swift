//
//  AbsencesDetailScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 27.10.2024.
//

import Charts
import SwiftData
import SwiftUI

enum TimeRange {
    case last30Days
    case last12Months
}

struct AbsencesDetailScreen: View {
    @State private var timeRange: TimeRange = .last30Days
    
    @Environment(\.modelContext) private var context
    @Query private var absences: [Absence]
    @ObservedObject private var viewModel: AbsencesDetailViewModel = .init()
    
    @State var scrollPositionStart: Date = .now.addingTimeInterval(-1 * 3600 * 24 * 30)
    
    var scrollPositionEnd: Date {
        scrollPositionStart.addingTimeInterval(3600 * 24 * 30)
    }
    
    var scrollPositionString: String {
        scrollPositionStart.formatted(.dateTime.month().day())
    }
    
    var scrollPositionEndString: String {
        scrollPositionEnd.formatted(.dateTime.month().day().year())
    }
    
    @State private var currentMonthIndex: Int = Calendar.current.component(.month, from: .now)
    @State private var lastMonthIndex: Int = Calendar.current.component(.month, from: Calendar.current.date(
        byAdding: .month,
        value: -1,
        to: Date.now
    )!)

    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading) {
                    TimeRangePicker(value: $timeRange)
                        .padding(.bottom)
                    Text("Total Absences")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        
                    if !absences.isEmpty {
                        switch timeRange {
                        case .last30Days:
                            Text(
                                "\(viewModel.getAbsencesCount(in: scrollPositionStart ... scrollPositionEnd, for: absences), format: .number) Absences"
                            )
                            .font(.title2.bold())
                            Text(
                                "\(viewModel.getUnexcusedAbsencesCount(in: scrollPositionStart ... scrollPositionEnd, for: absences), format: .number) unexcused"
                            )
                            .font(.callout)
                            .foregroundStyle(.secondary)

                            Text("\(scrollPositionString) – \(scrollPositionEndString)")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                
                            DailyAbsencesChart(
                                scrollPosition: $scrollPositionStart,
                                absences: viewModel
                                    .getAbsencesCountByDay(
                                        for: absences
                                    )
                            )
                            .frame(height: 240)
                        case .last12Months:
                            Text("\(absences.count, format: .number) Absences")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            Text(
                                "\(absences.filter { !$0.excused }.count, format: .number) unexcused"
                            )
                            .font(.callout)
                            .foregroundStyle(.secondary)

                            MonthlyAbsencesChart(absences: viewModel.getAbsencesCountByMonth(for: absences))
                                .frame(height: 240)
                        }
                    } else {
                        Text("\(absences.count, format: .number) Absences")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                    }
                }
                .transaction {
                    $0.animation = nil
                }
                
                AbsenceEvolutionCard(
                    absencesThisMonth: viewModel
                        .getAbsencesCount(
                            in: Calendar.current
                                .firstAndLastDay(
                                    forMonth: currentMonthIndex
                                )!.first ... Calendar.current
                                .firstAndLastDay(
                                    forMonth: currentMonthIndex
                                )!.last,
                            for: absences
                        ),
                    absencesLastMonth: viewModel
                        .getAbsencesCount(
                            in: Calendar.current
                                .firstAndLastDay(
                                    forMonth: lastMonthIndex
                                )!.first ... Calendar.current
                                .firstAndLastDay(
                                    forMonth: lastMonthIndex
                                )!.last,
                            for: absences
                        ),
                    currentMonthIndex: currentMonthIndex,
                    lastMonthIndex: lastMonthIndex
                )
                
                AverageAbsencesCard(
                    absences: viewModel.getAbsencesCountByMonth(for: absences),
                    average: viewModel.getAverageAbsencesByMonth(for: absences)
                )
            }
            .listSectionSpacing(10)
            .navigationBarTitle("Absences", displayMode: .inline)
        }
    }
}

#Preview {
    AbsencesDetailScreen()
}
