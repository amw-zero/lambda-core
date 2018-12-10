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
    func execute<UseCaseT: UseCase>(_ effect: Effect<UseCaseT.Action>, withOrchestrator orchestrator: LoginOrchestrator<UseCaseT>)
}

public protocol ExecutorProducer {
    func executorFor(effectType: EffectType) -> Executor
}

public protocol Orchestratable {
    associatedtype UseCaseT: UseCase
    var orchestrator: LoginOrchestrator<UseCaseT>! { get set }
}

public protocol UseCase {
    associatedtype State
    associatedtype Action
    init()
    func receive(_ action: Action, inState state: State) -> (State, Effect<Action>?)
}

public enum EffectType {
    case composite
    case viewTransition
    case setRootView
    case httpRequest
}

public enum Effect<Action> {
    case composite([Effect<Action>])
    case viewTransition(toView: View)
    case setRootView(view: View)
    case httpRequest(method: String, path: String, completion: (String) -> Action?)
    
    public var type: EffectType {
        switch self {
        case .composite:
            return .composite
        case .viewTransition:
            return .viewTransition
        case .setRootView:
            return .setRootView
        case .httpRequest:
            return .httpRequest
        }
    }
}

// This can probably be made generic, a la the Elm runtime. Orchestrator<UseCase, UseCaseState>
public class LoginOrchestrator<UseCaseT: UseCase> {
    public typealias State = UseCaseT.State
    public typealias Action = UseCaseT.Action
    let useCase: UseCaseT = UseCaseT()
    var state: State
    public var onNewState: (State) -> Void
    public let executorFactory: ExecutorProducer
    public init(state: State, executorFactory: ExecutorProducer, onNewState: @escaping (State) -> Void) {
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
        executorFactory.executorFor(effectType: efct.type).execute(efct, withOrchestrator: self)
    }
}
