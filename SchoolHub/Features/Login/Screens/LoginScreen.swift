//
//  LoginScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import SwiftUI

struct LoginScreen: View {
    @ObservedObject var viewModel: LoginViewModel = .init()
    @Environment(\.dismiss) var dismiss
    @State private var requestUrl: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isError: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField(
                        "Request URL",
                        text: $requestUrl
                    )
                    .textInputAutocapitalization(.never)
                    TextField(
                        "Username",
                        text: $username
                    )
                    .textInputAutocapitalization(.never)
                    SecureField(
                        "Password",
                        text: $password
                    )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
//                    Text("\(viewModel.keychainData.username ?? "nimic")")
                }
                Button("Login") {
                    Task {
                        let success = await viewModel.login(
                            username: username,
                            password: password,
                            requestUrl: requestUrl
                        )
                        
                        if success {
                            dismiss()
                        } else {
                            isError = true
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                if isError {
                    Section {
                        Text("Login failed")
                            .foregroundColor(.red)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LoginScreen()
}
