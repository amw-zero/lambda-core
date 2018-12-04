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

enum LoginButtonState {
    case password
    case sso
}

class ViewController: UIViewController {
    var loginButtonState: LoginButtonState = .password
    var orchestrator: LoginOrchestrator!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonTopConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        orchestrator = LoginOrchestrator { [weak self] state in
            self?.render(state)
        }
        emailTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    }
    func render(_ state: LoginState) {
        UIView.animate(withDuration: 1.0) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            if case state.authenticationScheme = AuthenticationScheme.sso {
                strongSelf.transformLoginButton(topPadding: 60.0, isHidden: true, title: "Login with SSO")
            } else {
                strongSelf.transformLoginButton(topPadding: 90.0, isHidden: false, title: "Login")
            }
        }
    }
    @objc func textChanged(_ textField: UITextField) {
        orchestrator.receive(
            .credentialInfoInput(userName: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        )
    }
    func transformLoginButton(topPadding: CGFloat, isHidden: Bool, title: String) {
        loginButtonTopConstraint.constant = topPadding
        passwordLabel.isHidden = isHidden
        passwordTextField.isHidden = isHidden
        loginButton.setTitle(title, for: .normal)
    }
}
