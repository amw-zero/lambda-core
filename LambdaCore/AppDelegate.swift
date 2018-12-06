//
//  AppDelegate.swift
//  LambdaCore
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import UIKit
import LambdaCoreCore
import LambdaCoreApplication

struct AppState {
    let currentUser: User?
    var executorFactory: ExecutorFactory!
}
// let user = User(email: "alex.weisberger@viewthespace.com")
var user: User?
var appState = AppState(currentUser: user, executorFactory: nil)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        appState.executorFactory = ExecutorFactory(window: window)
        let orchestrator = LoginOrchestrator(executorFactory: appState.executorFactory) { _ in }
        if appState.currentUser != nil {
            orchestrator.receive(.handleLoggedInUser)
        } else {
            orchestrator.receive(.initiateLogin)
        }
        return true
    }
}

