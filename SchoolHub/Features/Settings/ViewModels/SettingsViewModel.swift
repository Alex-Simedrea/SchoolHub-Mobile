//
//  HomeViewModel.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import Foundation

class SettingsViewModel: ObservableObject {
    @Published var username: String? = Auth.shared.getCredentials().username
    
    func logout() {
        Auth.shared.logout()
    }
}
