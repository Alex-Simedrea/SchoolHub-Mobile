//
//  Auth.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import Foundation

class Auth: ObservableObject {
    struct Credentials {
        var username: String?
        var password: String?
    }

    enum KeychainKey: String {
        case username
        case password
    }
    
    static let shared = Auth()
    private let keychain: KeychainSwift = .init()
    
    @Published var loggedIn: Bool = false
    private init() {
        let existingCredentials = getCredentials()
        loggedIn = existingCredentials.username != nil && existingCredentials.password != nil
    }
    
    func getCredentials() -> Credentials {
        return Credentials(
            username: keychain.get("username"),
            password: keychain.get("password")
        )
    }
    
    func setCredentials(username: String, password: String) {
        keychain.set(username, forKey: "username")
        keychain.set(password, forKey: "password")
        
        loggedIn = true
    }
    
    func logout() {
        keychain.delete("username")
        keychain.delete("password")
        
        loggedIn = false
    }
}
