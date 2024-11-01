//
//  RootScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import SwiftUI

enum Tabs {
    case dashboard
    case subjects
    case settings
}

struct RootScreen: View {
    @State var selectedTab: Tabs = .dashboard
    @EnvironmentObject var auth: Auth
    
    var body: some View {
        if auth.loggedIn {
            TabView(selection: $selectedTab) {
                Tab("Dashboard", systemImage: "house", value: .dashboard) {
                    HomeScreen(selectedTab: $selectedTab)
                }
                Tab("Subjects", systemImage: "book", value: .subjects) {
                    SubjectsScreen()
                }
                Tab("Settings", systemImage: "gear", value: .settings) {
                    SettingsScreen()
                }
            }
        } else {
            LoginScreen()
        }
    }
}

#Preview {
    RootScreen()
        .environmentObject(Auth.shared)
}
