//
//  StatsCard.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import Charts
import SwiftUI

struct StatsCard: View {
    let title: String
    let systemName: String
    let color: Color

    let values: [String]
    let labels: [String]

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Image(systemName: systemName)
                    .fontWeight(.medium)
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(color)
            }
            HStack(alignment: .top) {
                StatGroup(value: values[0], label: labels[0])
                Divider()
                StatGroup(value: values[1], label: labels[1])
                Divider()
                StatGroup(value: values[2], label: labels[2])
            }
        }
//        .padding()
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.vertical, 8)
//        .background(Color(.secondarySystemGroupedBackground))
//        .cornerRadius(10)
    }
}

#Preview {
    StatsCard(title: "Grades", systemName: "chart.bar.fill", color: Color(.blue), values: ["10", "3", "12"], labels: ["overall average", "this week", "this month"])
}

struct StatGroup: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 0) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(-10)
        }
        .frame(maxWidth: .infinity)
    }
}
