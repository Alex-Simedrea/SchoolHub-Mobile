//
//  LoginScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 13.10.2024.
//

import SwiftUI

struct LoginScreen: View {
    @ObservedObject var viewModel: LoginViewModel = .init()

    var body: some View {
        NavigationStack {
            List {
                Section {
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
                    Text("\(viewModel.keychainData.username ?? "nimic")")
                }
                Button("Login") {
                    viewModel.login()
                }
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Login")
        }
    }
}

#Preview {
    LoginScreen()
}
