//
//  LoginOrchestrator.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation
import LambdaCoreCore


struct HTTPRequest {
    let method: String
    let path: String
}

struct HTTPRequestExecutor {
    func execute(request:  HTTPRequest, callback: @escaping (String) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            callback("gmail.com")
        }
    }
}

public protocol Executor {
    func execute()
}

public protocol ExecutorProducer {
    func executorFor(effect: Effect, withOrchestrator: LoginOrchestrator) -> Executor
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
        switch efct {
        case let .httpRequest(method, path, completion):
            let request = HTTPRequest(method: method, path: path)
            HTTPRequestExecutor().execute(request: request) { [weak self] response in
                guard let action = completion(response) else {
                    return
                }
                self?.receive(action)
            }
        case .setRootView, .composite:
            executorFactory.executorFor(effect: efct, withOrchestrator: self).execute()
            break
        default:
            break
        }
    }
}
