//
//  HomeScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel = .init()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.gray)
                        Text(viewModel.username ?? "Username")
                    }
                }
                Button("Log out") {
                    viewModel.logout()
                }
                .foregroundStyle(.red)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsScreen()
}
