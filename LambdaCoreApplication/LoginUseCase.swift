//
//  LoginUseCase.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation

public enum LoginAction: Equatable {
    case initiateLogin
    case handleLoggedInUser
    case credentialInfoInput(userName: String, password: String)
    case ssoDomainsReceived([String])
}

public enum View {
    case home
    case login
}

public enum Effect {
    case composite([Effect])
    case viewTransition
    case setRootView(view: View)
    case httpRequest(method: String, path: String, completion: (String) -> LoginAction?)
}

public enum AuthenticationScheme: Equatable {
    case password(validCredentials: Bool)
    case sso
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
            let request = Effect.httpRequest(
                method: "get",
                path: "api/sso_domains",
                completion: { .ssoDomainsReceived([$0]) }
            )
            let setRootView = Effect.setRootView(view: .login)
            return (state, .composite([request, setRootView]))
        case .handleLoggedInUser:
            return (state, .setRootView(view: .home))
        case .credentialInfoInput(let userName, let password):
            return credentialCheck(userName, password, state)
        case .ssoDomainsReceived(let ssoDomains):
            let nextState = LoginState(authenticationScheme: state.authenticationScheme, ssoDomains: ssoDomains)
            return (nextState, nil)
        }
    }
    func credentialCheck(_ userName: String, _ password: String, _ state: LoginState) -> (LoginState, Effect?) {
        if email(userName, isWithin: state.ssoDomains) {
            // Want to update only 1 (or N) properties, not specify all each time
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
    func email(_ userName: String, isWithin ssoDomains: [String]) -> Bool {
        return ssoDomains.contains { (ssoDomain) -> Bool in
            return userName.contains(ssoDomain)
        }
    }
}
