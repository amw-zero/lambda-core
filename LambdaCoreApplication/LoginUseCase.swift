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

struct LoginState: Equatable {
    let validEmail: Bool
    init(validEmail: Bool = false) {
        self.validEmail = validEmail
    }
}

struct LoginUseCase {
    func receive(_ action: LoginAction, inState state: LoginState) -> (LoginState, Effect?) {
        switch action {
        case .initiateLogin:
            return (state, .viewTransition)
        case .credentialInfoInput(let username, let password):
            if validInput(username, password) {
                return (LoginState(validEmail: true), nil)
            } else {
                return (state, nil)
            }
        default:
            return (state, nil)
        }
    }
    func validInput(_ userName: String, _ password: String) -> Bool {
        return !userName.isEmpty && !password.isEmpty
    }
}
