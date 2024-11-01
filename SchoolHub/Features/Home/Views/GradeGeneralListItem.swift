//
//  GradeGeneralListItem.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 25.10.2024.
//

import SwiftUI

struct GradeGeneralListItem: View {
    let color: Color
    let symbolName: String
    let subjectName: String
    let date: Date
    let value: Int

    var body: some View {
        HStack(alignment: .top) {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(color)
                    .overlay {
                        Image(systemName: symbolName)
                            .foregroundStyle(.background)
                            .fontWeight(.semibold)
                    }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Grade".uppercased())
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                    Text(subjectName)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(date.formattedRelative())
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                Text(String(value))
                    .font(.title3)
                    .fontWeight(.medium)
            }
        }
    }
}

#Preview {
    GradeGeneralListItem(
        color: .green,
        symbolName: "x.squareroot",
        subjectName: "Matematica",
        date: Calendar.current.date(byAdding: .day, value: -10, to: .now)!,
        value: 10
    )
}
