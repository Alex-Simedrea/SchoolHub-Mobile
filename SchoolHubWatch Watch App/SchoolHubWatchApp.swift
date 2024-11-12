//
//  SchoolHubWatchApp.swift
//  SchoolHubWatch Watch App
//
//  Created by Alexandru Simedrea on 10.11.2024.
//

import SwiftUI

@main
struct SchoolHubWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Subject.self])
        }
    }
}
