//
//  AppDelegate.swift
//  LambdaCore
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import UIKit
import LambdaCoreModel
import LambdaCoreApplication

struct AppState {
    var currentUser: User?
    var executorFactory: ExecutorFactory
    init(currentUser: User? = nil, executorFactory: ExecutorFactory = ExecutorFactory(window: nil)) {
        self.currentUser = currentUser
        self.executorFactory = executorFactory
    }
}
// let user = User(email: "alex.weisberger@viewthespace.com")
var user: User?
var appState = AppState(currentUser: user)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        appState.executorFactory = ExecutorFactory(window: window)
        let orchestrator = Orchestrator<LoginUseCase>(state: LoginState(), executorFactory: appState.executorFactory) { _ in }
        if let user = appState.currentUser {
            orchestrator.receive(.loginSucceeded(forUser: user))
        } else {
            orchestrator.receive(.initiateLogin)
        }
        return true
    }
}

