//
//  LoginOrchestrator.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation
import LambdaCoreCore
// This can probably be made generic, a la the Elm runtime. Orchestrator<UseCase, UseCaseState>
public class LoginOrchestrator {
    let useCase: LoginUseCase = LoginUseCase()
    var state: LoginState = LoginState()
    let onNewState: (LoginState) -> Void
    public init(onNewState: @escaping (LoginState) -> Void) {
        self.onNewState = onNewState
    }
    public func receive(_ action: LoginAction) {
        let (newState, _) = useCase.receive(action, inState: state)
        state = newState
        onNewState(newState)
    }
}
