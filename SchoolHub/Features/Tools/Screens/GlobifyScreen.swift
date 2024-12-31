//
//  GlobifyScreem.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 24.12.2024.
//

import SwiftUI
import WebKit

struct GlobifyScreen: View {
    var body: some View {
        NavigationStack {
            WebView(url: URL(string: "https://globify-brasov.vercel.app"))
                .navigationTitle("Globify")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    GlobifyScreen()
}
