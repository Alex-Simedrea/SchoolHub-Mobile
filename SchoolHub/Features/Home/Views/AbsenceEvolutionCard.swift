//
//  AbsenceEvolutionCard.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 29.10.2024.
//

import SwiftUI

struct AbsenceEvolutionCard: View {
    @State var absencesThisMonth: Int
    @State var absencesLastMonth: Int
    
    @State var currentMonthIndex: Int
    @State var lastMonthIndex: Int
    
    var comparisonText: String {
        let difference = absencesThisMonth - absencesLastMonth
        
        switch difference {
        case 0:
            return "You have the same amount of absences as last month."
        case 1:
            return "You have 1 more absence this month compared to last month."
        case let x where x > 1:
            return "You have \(x) more absences this month compared to last month."
        case -1:
            return "You have 1 less absence this month compared to last month."
        default:
            return "You have \(abs(difference)) less absences this month compared to last month."
        }
    }
    
    var normalizedNumbers: (current: Double, previous: Double) {
        if absencesThisMonth == 0 && absencesLastMonth == 0 {
            return (0.02, 0.02)
        }
        
        let thisMonth = absencesThisMonth == 0 ? Double(absencesLastMonth) * 0.02 : Double(absencesThisMonth)
        let lastMonth = absencesLastMonth == 0 ? Double(absencesThisMonth) * 0.02 : Double(absencesLastMonth)
        
        if thisMonth >= lastMonth {
            return (1, lastMonth/thisMonth)
        } else {
            return (thisMonth/lastMonth, 1)
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
        Section("Highlights") {
            CardTemplate(
                systemName: "calendar",
                title: "Absences",
                color: Color(.tangerine)
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(comparisonText)
                        .font(.headline)
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        (Text("\(absencesThisMonth)")
                            .font(.title2)
                            .fontWeight(.semibold)
                         + Text(" \(absencesThisMonth == 1 ? "absence" : "absences")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        )
                        .padding(.leading, 40)
                        HStack {
                            Text(
                                "\(Calendar.current.date(from: DateComponents(month: currentMonthIndex))?.formatted(.dateTime.month(.abbreviated)) ?? "")"
                            )
                            .font(.system(size: 16))
                            .frame(width: 32, alignment: .leading)
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(Color(.tangerine))
                                    .frame(
                                        width: geometry.size.width * normalizedNumbers.current,
                                        height: 24
                                    )
                            }
                        }
                        .frame(height: 24)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        (Text("\(absencesLastMonth)")
                            .font(.title2)
                            .fontWeight(.semibold)
                         + Text(" \(absencesLastMonth == 1 ? "absence" : "absences")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        )
                        .padding(.leading, 40)
                        HStack {
                            Text(
                                "\(Calendar.current.date(from: DateComponents(month: lastMonthIndex))?.formatted(.dateTime.month(.abbreviated)) ?? "")"
                            )
                            .frame(width: 32, alignment: .leading)
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundStyle(Color(.tangerine))
                                    .frame(
                                        width: geometry.size.width * normalizedNumbers.previous,
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
        .headerProminence(.increased)
    }
}

//#Preview {
//    AbsenceEvolutionCard()
//}
