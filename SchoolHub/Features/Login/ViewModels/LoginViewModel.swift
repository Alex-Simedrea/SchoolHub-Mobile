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
        Auth.shared.setCredentials(username: username, password: password, requestUrl: requestUrl)

        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print(
            "COOKY: \(String(describing: HTTPCookieStorage.shared.cookies(for: URL(string: "https://noteincatalog.ro")!)))"
        )

        let cookieResponse = await AF.request(
            requestUrl,
            method: .get
        ).serializingResponse(using: .data).response

        guard let cookie = cookieResponse.response?.headers["Set-Cookie"] else {
            print("failed cookie")
            print(cookieResponse.response?.headers)
            return false
        }

        if cookieResponse.response?.statusCode == 200 {
            print(
                "COOKY: \(String(describing: HTTPCookieStorage.shared.cookies(for: URL(string: "https://noteincatalog.ro")!)))"
            )
            let oldCookie = HTTPCookieStorage.shared.cookies(
                for: URL(string: "https://noteincatalog.ro")!
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
                    print(
                        "COOKY NEW: \(String(describing: HTTPCookieStorage.shared.cookies(for: URL(string: "https://noteincatalog.ro")!)))"
                    )
                }
            }

//            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

//            HTTPCookieStorage.shared.setCookie(<#T##cookie: HTTPCookie##HTTPCookie#>)

            let loginResponse = try! await AF.request(
                requestUrl,
                method: .post,
                parameters: [
                    "txtUser": username,
                    "txtPwd": password
                ]
            ).serializingResponse(using: .data).value

            print(String(data: loginResponse, encoding: .utf8))
        }

        return true

//        do {
//            let response = try String(
//                data: await AF.request(
//                    requestUrl,
//                    method: .post,
//                    parameters: [
//                        "txtUser": username,
//                        "txtPwd": password
//                    ],
//                    headers: [
//                        "Cookie": cookie
//                    ]
//                ).serializingData().value,
//                encoding: .utf8
//            )!
//
//            if response.contains("table") {
//                print(response)
//                Auth.shared.setCookie(cookie: cookie)
//
//                return true
//            } else {
//                print("failed table")
//                print(response)
//                let retryResponse = try String(
//                    data: await AF.request(
//                        requestUrl,
//                        method: .post,
//                        parameters: [
//                            "txtUser": username,
//                            "txtPwd": password
//                        ],
//                        headers: [
//                            "Cookie": cookie
//                        ]
//                    ).serializingData().value,
//                    encoding: .utf8
//                )!
//
//                if retryResponse.contains("table") {
//                    Auth.shared.setCookie(cookie: cookie)
//
//                    return true
//                } else {
//                    print("failed retry")
//                    print(retryResponse)
//                    return false
//                }
//            }
//        } catch {
//            print("failed post request")
//            return false
//        }
    }
}
