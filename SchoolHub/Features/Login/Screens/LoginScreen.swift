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

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField(
                        "Request URL",
                        text: $viewModel.requestUrl
                    )
                    .textInputAutocapitalization(.never)
                    TextField(
                        "Username",
                        text: $viewModel.username
                    )
                    .textInputAutocapitalization(.never)
                    SecureField(
                        "Password",
                        text: $viewModel.password
                    )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
//                    Text("\(viewModel.keychainData.username ?? "nimic")")
                }
                Button("Login") {
                    viewModel.login()
                    dismiss()
                }
                .frame(maxWidth: .infinity)
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
