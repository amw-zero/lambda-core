//
//  ViewController.swift
//  LambdaCore
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import UIKit
import LambdaCoreCore
import LambdaCoreApplication
class ViewController: UIViewController {
    var orchestrator: LoginOrchestrator!
    override func viewDidLoad() {
        super.viewDidLoad()
        orchestrator = LoginOrchestrator { [weak self] state in
            self?.render(state)
        }
        orchestrator.receive(.credentialInfoInput(username: "user@gmail.com", password: ""))
    }
    func render(_ state: LoginState) {
        if case state.authenticationScheme = AuthenticationScheme.sso {
            print("animating sso button")
        }
    }
}

