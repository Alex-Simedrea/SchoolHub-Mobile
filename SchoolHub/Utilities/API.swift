//
//  API.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 20.12.2024.
//

import Foundation

class API {
    var baseURL: URL = URL(string: "http://localhost:3000/")!
    
    static let shared = API()
}
