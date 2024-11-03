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
        var requestUrl: String?
    }

    enum KeychainKey: String {
        case username
        case password
        case requestUrl
    }
    
    static let shared = Auth()
    private let keychain: KeychainSwift = .init()
    
    @Published var loggedIn: Bool = false
    private init() {
        let existingCredentials = getCredentials()
        loggedIn = existingCredentials.username != nil && existingCredentials.password != nil && existingCredentials.requestUrl != nil
    }
    
    func getCredentials() -> Credentials {
        return Credentials(
            username: keychain.get("username"),
            password: keychain.get("password"),
            requestUrl: keychain.get("requestUrl")
        )
    }
    
    func setCredentials(username: String, password: String, requestUrl: String) {
        keychain.set(username, forKey: "username")
        keychain.set(password, forKey: "password")
        keychain.set(requestUrl, forKey: "requestUrl")
        
        loggedIn = true
    }
    
    func logout() {
        keychain.delete("username")
        keychain.delete("password")
        keychain.delete("requestUrl")
        
        loggedIn = false
    }
}
