//
//  LoginViewModel.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import Alamofire
import Foundation

class LoginViewModel: ObservableObject {
    func login(
        username: String,
        password: String,
        requestUrl: String
    ) async -> Bool {
        DispatchQueue.main.async {
            Auth.shared.setCredentials(username: username, password: password, requestUrl: requestUrl)
        }

        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        let cookieResponse = await AF.request(
            requestUrl,
            method: .get
        ).serializingResponse(using: .data).response

        guard let _ = cookieResponse.response?.headers["Set-Cookie"] else {
            return false
        }

        if cookieResponse.response?.statusCode == 200 {
            let oldCookie = HTTPCookieStorage.shared.cookies(
                for: URL(string: requestUrl)!
            )?.first!

            if let oldCookie = oldCookie {
                let newCookie = HTTPCookie(properties: [
                    .name: oldCookie.name,
                    .value: oldCookie.value,
                    .expires: Date(timeIntervalSinceNow: 60 * 60 * 24 * 365),
                    .domain: oldCookie.domain,
                    .path: oldCookie.path
                ])

                if let newCookie = newCookie {
                    HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
                    HTTPCookieStorage.shared.setCookie(newCookie)
                }
            }

            do  {
                let _ = try await AF.request(
                    requestUrl,
                    method: .post,
                    parameters: [
                        "txtUser": username,
                        "txtPwd": password
                    ]
                ).serializingResponse(using: .string).value
            } catch {
                print(error.localizedDescription)
                return false
            }
        }

        return true
    }
}
