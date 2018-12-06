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
    func execute(withOrchestrator orchestrator: LoginOrchestrator) {
        window.rootViewController = ViewControllerFactory.from(view: view, withOrchestrator: orchestrator)
        window.makeKeyAndVisible()
    }
}

struct NullExecutor: Executor {
    func execute(withOrchestrator: LoginOrchestrator) {
        
    }
}

struct HTTPRequest {
    let method: String
    let path: String
}

struct HTTPRequestExecutor: Executor {
    let httpRequest: HTTPRequest
    let completion: (String) -> LoginAction?
    func execute(withOrchestrator orchestrator: LoginOrchestrator) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            guard let action = self.completion("gmail.com") else {
                return
            }
            orchestrator.receive(action)
        }
    }
}

struct CompositeExecutor: Executor {
    let effects: [Effect]
    func execute(withOrchestrator orchestrator: LoginOrchestrator) {
        for effect in effects {
            appState.executorFactory.executorFor(effect: effect)
                .execute(withOrchestrator: orchestrator)
        }
    }
}

struct ExecutorFactory: ExecutorProducer {
    weak var window: UIWindow?
    func executorFor(effect: Effect) -> Executor {
        switch effect {
        case let .setRootView(view):
            guard let wdw = window else {
                return NullExecutor()
            }
            return RootViewExecutor(window: wdw, view: view)
        case let .composite(effects):
            return CompositeExecutor(effects: effects)
        case .httpRequest:
            if case let .httpRequest(method, path, completion) = effect {
                let httpRequest = HTTPRequest(method: method, path: path)
                return HTTPRequestExecutor(httpRequest: httpRequest, completion: completion)
            } else {
                return NullExecutor()
            }

        default:
            return NullExecutor()
        }
    }
}
