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
    static func from(view: View, withOrchestrator orchestrator: LoginOrchestrator) -> UIViewController {
        var storyboardName: String
        switch view {
        case .home:
            storyboardName = "Home"
        case .login:
            storyboardName = "Main"
        }
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        var orchestratable = vc as! Orchestratable
        orchestratable.orchestrator = orchestrator
        return vc
    }
}

struct RootViewExecutor: Executor {
    let window: UIWindow
    let view: View
    let orchestrator: LoginOrchestrator
    func execute() {
        window.rootViewController = ViewControllerFactory.from(view: view, withOrchestrator: orchestrator)
        window.makeKeyAndVisible()
    }
}

struct NullRootViewExecutor: Executor {
    func execute() {
        
    }
}

struct CompositeExecutor: Executor {
    let effects: [Effect]
    let orchestrator: LoginOrchestrator
    func execute() {
        for effect in effects {
            appState.executorFactory.executorFor(
                effect: effect,
                withOrchestrator: orchestrator
                ).execute()
        }
    }
}

struct ExecutorFactory: ExecutorProducer {
    weak var window: UIWindow?
    func executorFor(effect: Effect, withOrchestrator orchestrator: LoginOrchestrator) -> Executor {
        switch effect {
        case let .setRootView(view):
            guard let wdw = window else {
                return NullRootViewExecutor()
            }
            return RootViewExecutor(window: wdw, view: view, orchestrator: orchestrator)
        case let .composite(effects):
            return CompositeExecutor(effects: effects, orchestrator: orchestrator)
        default:
            return NullRootViewExecutor()
        }
    }
}
