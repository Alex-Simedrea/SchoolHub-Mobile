//
//  SchoolHubApp.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 12.10.2024.
//

import SwiftData
import SwiftUI

@main
struct SchoolHubApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Subject.self])
        }
    }
}
