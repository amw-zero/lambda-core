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
    associatedtype UseCaseT: UseCase
    associatedtype ExProducer: ExecutorProducer
    func execute(withOrchestrator: LoginOrchestrator<UseCaseT, ExProducer>)
}

public protocol ExecutorProducer {
    func executorFor<T: Executor>(effect: Effect) -> T
}

public protocol Orchestratable {
    associatedtype UseCaseT: UseCase
    associatedtype ExProducer: ExecutorProducer
    var orchestrator: LoginOrchestrator<UseCaseT, ExProducer>! { get set }
}

public protocol UseCase {
    associatedtype State
    associatedtype Action
    func receive(_ action: Action, inState state: State) -> (State, Effect?)
}

// This can probably be made generic, a la the Elm runtime. Orchestrator<UseCase, UseCaseState>
public class LoginOrchestrator<UseCaseT: UseCase, ExProducer: ExecutorProducer> {
    public typealias State = UseCaseT.State
    public typealias Action = UseCaseT.Action
    let useCase: UseCaseT
    var state: State
    public var onNewState: (State) -> Void
    let executorFactory: ExProducer
    public init(useCase: UseCaseT, state: State, executorFactory: ExProducer, onNewState: @escaping (State) -> Void) {
        self.useCase = useCase
        self.state = state
        self.executorFactory = executorFactory
        self.onNewState = onNewState
    }
    public func receive(_ action: Action) {
        let (newState, effect) = useCase.receive(action, inState: state)
        state = newState
        onNewState(newState)
        guard let efct = effect else {
            return
        }
        executorFactory.executorFor(effect: efct).execute(withOrchestrator: self)
    }
}

// Orchestrator --> UseCase, Executor --> State, Action
