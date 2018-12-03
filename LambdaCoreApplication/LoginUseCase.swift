//
//  LoginUseCase.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation
enum LoginAction {
    case initiateLogin
    case credentialInfoInput(username: String, password: String)
}

enum Effect {
    case viewTransition
}

enum AuthenticationScheme {
    case password(validCredentials: Bool)
}

extension AuthenticationScheme: Equatable {
    static func == (lhs: AuthenticationScheme, rhs: AuthenticationScheme) -> Bool {
        switch (lhs, rhs) {
        case (.password(let lValidCredentials), .password(let rValidCredentials)):
            return lValidCredentials == rValidCredentials
        }
    }
}

struct LoginState: Equatable {
    let authenticationScheme: AuthenticationScheme
    init(authenticationScheme: AuthenticationScheme = .password(validCredentials: false)) {
        self.authenticationScheme = authenticationScheme
    }
}

struct LoginUseCase {
    func receive(_ action: LoginAction, inState state: LoginState) -> (LoginState, Effect?) {
        switch action {
        case .initiateLogin:
            return (state, .viewTransition)
        case .credentialInfoInput(let username, let password):
            if validInput(username, password) {
                return (LoginState(authenticationScheme: .password(validCredentials: true)), nil)
            } else {
                return (state, nil)
            }
        }
    }
    func validInput(_ userName: String, _ password: String) -> Bool {
        return !userName.isEmpty && !password.isEmpty
    }
}
