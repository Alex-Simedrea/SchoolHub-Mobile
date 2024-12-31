//
//  ToolsScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 24.12.2024.
//

import SwiftUI

struct ToolsScreen: View {
    let tools: [ToolCard] = [
        .init(
            symbolName: "number",
            title: "Averages Calculator",
            description: "Get help calculating your averages with smart suggestions",
            color: .blue
        ) {
            AveragesScreen()
        },
        .init(
            symbolName: "checkmark.square",
            title: "QuizCraft",
            description: "Create quizzes and test your knowledge",
            color: .indigo
        ) {
            QuizCraftScreen()
        },
        .init(
            symbolName: "book.fill",
            title: "Literaria",
            description: "Check out the latest literature articles",
            color: .orange
        ) {
            LiterariaScreen()
        },
        .init(
            symbolName: "globe.europe.africa.fill",
            title: "Globify",
            description: "Learn about different layers of the Earth",
            color: .green
        ) {
            GlobifyScreen()
        },
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tools, id: \.title) { tool in
                    Section {
                        tool
                    }
                }
            }
            .listSectionSpacing(12)
            .navigationTitle("Tools")
        }
    }
}

struct ToolCard: View {
    let symbolName: String
    let title: String
    let description: String
    let color: Color
    let destination: () -> any View
    
    init(
        symbolName: String,
        title: String,
        description: String,
        color: Color,
        @ViewBuilder destination: @escaping () -> any View
    ) {
        self.symbolName = symbolName
        self.title = title
        self.description = description
        self.color = color
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink(
            destination: AnyView(destination())
        ) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: symbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(8)
                    .foregroundStyle(.white)
                    .bold()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color)
                    }
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    ToolsScreen()
}
