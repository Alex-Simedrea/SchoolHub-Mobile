//
//  AbsenceGeneralListItem.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 25.10.2024.
//

import SwiftUI

struct AbsenceGeneralListItem: View {
    let color: Color
    let symbolName: String
    let subjectName: String
    let excused: Bool
    let date: Date
    
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
                    Text("Absence".uppercased())
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
                HStack(spacing: 4) {
                    if excused {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Excused")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        Text("Not excused")
//                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
}

#Preview {
    AbsenceGeneralListItem(
        color: .blue,
        symbolName: "book.fill",
        subjectName: "Romana",
        excused: false,
        date: .now
    )
}
