//
//  LoginOrchestrator.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation
import LambdaCoreModel

public protocol Executor {
    func execute(withOrchestrator: LoginOrchestrator)
}

public protocol ExecutorProducer {
    func executorFor(effect: Effect) -> Executor
}

public protocol Orchestratable {
    var orchestrator: LoginOrchestrator! { get set }
}

// This can probably be made generic, a la the Elm runtime. Orchestrator<UseCase, UseCaseState>
public class LoginOrchestrator {
    let useCase: LoginUseCase = LoginUseCase()
    var state: LoginState = LoginState()
    public var onNewState: (LoginState) -> Void
    let executorFactory: ExecutorProducer
    public init(executorFactory: ExecutorProducer, onNewState: @escaping (LoginState) -> Void) {
        self.executorFactory = executorFactory
        self.onNewState = onNewState
    }
    public func receive(_ action: LoginAction) {
        let (newState, effect) = useCase.receive(action, inState: state)
        state = newState
        onNewState(newState)
        guard let efct = effect else {
            return
        }
        executorFactory.executorFor(effect: efct).execute(withOrchestrator: self)
    }
}
