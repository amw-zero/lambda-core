//
//  Executors.swift
//  LambdaCore
//
//  Created by Alex Weisberger on 12/5/18.
//  Copyright © 2018 vts. All rights reserved.
//

import UIKit
import LambdaCoreApplication

struct ViewControllerFactory {
    static func from<UseCase>(view: View, withOrchestrator orchestrator: LoginOrchestrator<UseCase>) -> UIViewController {
        var storyboardName: String
        switch view {
        case .home:
            storyboardName = "Home"
        case .login:
            storyboardName = "Main"
        }
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        switch view {
        case .home:
            let homeVC = vc as! HomeViewController
            homeVC.orchestrator = LoginOrchestrator<ViewAssetsUseCase>(state: ViewAssetsState(), executorFactory: appState.executorFactory) { _ in }
        case .login:
            let loginVC = vc as! ViewController
            loginVC.orchestrator = LoginOrchestrator(state: LoginState(), executorFactory: appState.executorFactory) { _ in }
        }
        return vc
    }
    static func attach<T: Orchestratable>(orchestrator: LoginOrchestrator<T.UseCaseT>, toOrchestratable orchestratable: inout T) {
        orchestratable.orchestrator = orchestrator
    }
}

struct RootViewExecutor: Executor {
    let window: UIWindow
    func execute<UseCaseT: UseCase>(_ effect: Effect<UseCaseT.Action>, withOrchestrator orchestrator: LoginOrchestrator<UseCaseT>) {
        print("changing root view")
        if case let .setRootView(view) = effect {
            window.rootViewController = ViewControllerFactory.from(view: view, withOrchestrator: orchestrator)
            window.makeKeyAndVisible()
        }
    }
}

struct NullExecutor: Executor {
    func execute<UseCaseT: UseCase>(_ effect: Effect<UseCaseT.Action>, withOrchestrator orchestrator: LoginOrchestrator<UseCaseT>) {
    }
}

struct HTTPRequest {
    let method: String
    let path: String
}

struct HTTPRequestExecutor: Executor {
    func execute<UseCaseT: UseCase>(_ effect: Effect<UseCaseT.Action>, withOrchestrator orchestrator: LoginOrchestrator<UseCaseT>) {
        guard case let .httpRequest(method, path, completion) = effect else {
            return
        }
        let _: HTTPRequest = HTTPRequest(method: method, path: path)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            guard let action = completion("gmail.com") else {
                return
            }
            orchestrator.receive(action)
        }
    }
}

struct CompositeExecutor: Executor {
    func execute<UseCaseT: UseCase>(_ effect: Effect<UseCaseT.Action>, withOrchestrator orchestrator: LoginOrchestrator<UseCaseT>) {
        guard case let .composite(effects) = effect else {
            return
        }
        for singleEffect in effects {
            orchestrator.executorFactory.executorFor(effectType: singleEffect.type)
                .execute(singleEffect, withOrchestrator: orchestrator)
        }
    }
}

struct ExecutorFactory: ExecutorProducer {
    weak var window: UIWindow?
    func executorFor(effectType: EffectType) -> Executor {
        switch effectType {
        case .setRootView:
            guard let wdw = window else {
                return NullExecutor()
            }
            return RootViewExecutor(window: wdw)
        case .composite:
            return CompositeExecutor()
        case .httpRequest:
            return HTTPRequestExecutor()
        default:
            return NullExecutor()
        }
    }
}
