//
//  LoginUseCase.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation
import LambdaCoreModel

public enum LoginAction: Equatable {
    case initiateLogin
    case credentialInfoInput(userName: String, password: String)
    case ssoDomainsReceived([String])
    case attemptLogin(withUserName: String, andPassword: String)
    case loginSucceeded(forUser: User)
}

public enum View {
    case home
    case login
}

public enum Effect {
    case composite([Effect])
    case viewTransition(toView: View)
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
    public init(authenticationScheme: AuthenticationScheme = .password(validCredentials: false), ssoDomains: [String] = []) {
        self.authenticationScheme = authenticationScheme
        self.ssoDomains = ssoDomains
    }
}

public struct LoginUseCase: UseCase {
    public init() {
    }
    public func receive(_ action: LoginAction, inState state: LoginState) -> (LoginState, Effect?) {
        switch action {
        case .initiateLogin:
            let request = Effect.httpRequest(
                method: "get",
                path: "api/sso_domains",
                completion: { .ssoDomainsReceived([$0]) }
            )
            let setRootView = Effect.setRootView(view: .login)
            return (state, .composite([request, setRootView]))
        case .credentialInfoInput(let userName, let password):
            return credentialCheck(userName, password, state)
        case .ssoDomainsReceived(let ssoDomains):
            let nextState = LoginState(authenticationScheme: state.authenticationScheme, ssoDomains: ssoDomains)
            return (nextState, nil)
        case .attemptLogin:
            let request = Effect.httpRequest(
                method: "get",
                path: "/api/sign_in",
                completion: { .loginSucceeded(forUser: UserParser.user(from: $0)) })
            return (state, request)
        case .loginSucceeded:
            return (state, .setRootView(view: .home))
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

struct UserParser {
    static func user(from email: String) -> User {
        return User(email: email)
    }
}
