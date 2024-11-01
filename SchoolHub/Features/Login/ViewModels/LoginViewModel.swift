//
//  LoginViewModel.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    
    @Published var keychainData = Auth.shared.getCredentials()

    func login() {
        Auth.shared.setCredentials(username: username, password: password)
    }
}
