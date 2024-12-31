//
//  LiterariaScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 24.12.2024.
//

import SwiftUI

struct LiterariaScreen: View {
    var body: some View {
        NavigationStack {
            WebView(url: URL(string: "https://literaria.info"))
                .navigationTitle("Literaria")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LiterariaScreen()
}
