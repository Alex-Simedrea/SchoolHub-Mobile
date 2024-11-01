//
//  CardTemplate.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 14.10.2024.
//

import SwiftUI

struct CardTemplate<Content: View>: View {
    let systemName: String
    let title: String
    let color: Color
    
    private let Children: () -> Content
    
    init(systemName: String, title: String, color: Color, @ViewBuilder children: @escaping () -> Content) {
        self.systemName = systemName
        self.title = title
        self.color = color
        self.Children = children
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Image(systemName: systemName)
                    .fontWeight(.medium)
                    .foregroundStyle(color)
                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            Children()
        }
    }
}

#Preview {
    CardTemplate(systemName: "house", title: "ceva", color: .blue) {
        Text("string")
    }
}
