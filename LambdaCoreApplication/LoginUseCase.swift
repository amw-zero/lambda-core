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
}

protocol Effect {
    
}
struct ViewTransition: Effect {
}

extension ViewTransition: Equatable {
    static func == (lhs: ViewTransition, rhs: ViewTransition) -> Bool {
        return true
    }
}

struct LoginState {
    
}

extension LoginState: Equatable {
    static func == (lhs: LoginState, rhs: LoginState) -> Bool {
        return true
    }
}

struct LoginUseCase {
    func receive(_ action: LoginAction, inState state: LoginState) -> (LoginState, ViewTransition?) {
        return (state, ViewTransition())
    }
}
