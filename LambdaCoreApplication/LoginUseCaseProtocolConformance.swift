//
//  LoginUseCaseProtocolConformance.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/4/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation

extension LoginAction: Equatable {
    public static func == (lhs: LoginAction, rhs: LoginAction) -> Bool {
        switch (lhs, rhs) {
        case (.initiateLogin, .initiateLogin):
            return true
        case (let .credentialInfoInput(lUserName, lPassword), let .credentialInfoInput(rUserName, rPassword)):
            return lUserName == rUserName && lPassword == rPassword
        case (let .ssoDomainsReceived(lDomains), let .ssoDomainsReceived(rDomains)):
            return lDomains == rDomains
        default:
            return false
        }
    }
}

extension Effect: Equatable {
    static func == (lhs: Effect, rhs: Effect) -> Bool {
        switch (lhs, rhs) {
        case (.viewTransition, .viewTransition):
            return true
        case (
            .httpRequest(let lMethod, let lPath, let lCompletion),
            .httpRequest(let rMethod, let rPath, let rCompletion)
            ):
            return lMethod == rMethod && lPath == rPath && lCompletion("dummy") == rCompletion("dummy")
        default:
            return false
        }
    }
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
