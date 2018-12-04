//
//  LoginUseCase.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation
public enum LoginAction {
    case initiateLogin
    case credentialInfoInput(userName: String, password: String)
}

enum Effect {
    case viewTransition
}

public enum AuthenticationScheme {
    case password(validCredentials: Bool)
    case sso
}

extension AuthenticationScheme: Equatable {
    public static func == (lhs: AuthenticationScheme, rhs: AuthenticationScheme) -> Bool {
        switch (lhs, rhs) {
        case (.password(let lValidCredentials), .password(let rValidCredentials)):
            return lValidCredentials == rValidCredentials
        case (.sso, .sso):
            return true
        default:
            return false
        }
    }
}

public struct LoginState: Equatable {
    public let authenticationScheme: AuthenticationScheme
    public let ssoDomains: [String]
    init(authenticationScheme: AuthenticationScheme = .password(validCredentials: false), ssoDomains: [String] = []) {
        self.authenticationScheme = authenticationScheme
        self.ssoDomains = ssoDomains
    }
}

struct LoginUseCase {
    func receive(_ action: LoginAction, inState state: LoginState) -> (LoginState, Effect?) {
        switch action {
        case .initiateLogin:
            return (state, .viewTransition)
        case .credentialInfoInput(let userName, let password):
            return credentialCheck(userName, password, state)
        }
    }
    func credentialCheck(_ userName: String, _ password: String, _ state: LoginState) -> (LoginState, Effect?) {
        if isEmail(userName, in: state.ssoDomains) {
            let nextState = LoginState(authenticationScheme: .sso, ssoDomains: state.ssoDomains)
            return (nextState, nil)
        } else if isValidCredentials(userName, password) {
            let nextState = LoginState(authenticationScheme: .password(validCredentials: true), ssoDomains: state.ssoDomains)
            return (nextState, nil)
        } else {
            let nextState = LoginState(authenticationScheme: .password(validCredentials: false), ssoDomains: state.ssoDomains)
            return (nextState, nil)
        }
    }
    func isValidCredentials(_ userName: String, _ password: String) -> Bool {
        return !userName.isEmpty && !password.isEmpty
    }
    func isEmail(_ userName: String, in ssoDomains: [String]) -> Bool {
        return ssoDomains.contains { (ssoDomain) -> Bool in
            return userName.contains(ssoDomain)
        }
    }
}
