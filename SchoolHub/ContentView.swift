//
//  ContentView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 12.10.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        RootScreen()
            .environmentObject(Auth.shared)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Subject.self])
}
