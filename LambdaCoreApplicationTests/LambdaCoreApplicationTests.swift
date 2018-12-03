//
//  LambdaCoreApplicationTests.swift
//  LambdaCoreApplicationTests
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import XCTest
@testable import LambdaCoreApplication
class LambdaCoreApplicationTests: XCTestCase {
    func testInitiateLogin() {
        let useCase = LoginUseCase()
        let loginState = LoginState()
        let (state, effect) = useCase.receive(.initiateLogin, inState: loginState)
        XCTAssertEqual(effect, Effect.viewTransition)
        XCTAssertEqual(state, LoginState())
    }
    func testWhenNonSSOEmailAndPasswordAreNotInput() {
        let useCase = LoginUseCase()
        let loginState = LoginState()
        
        let username = ""
        let password = ""
        let (state, effect) = useCase.receive(
            .credentialInfoInput(username: username, password: password),
            inState: loginState
        )
        XCTAssertEqual(effect, nil)
        XCTAssertEqual(state, LoginState())
    }
    func testWhenValidNonSSOEmailAndPasswordAreInput() {
        let useCase = LoginUseCase()
        let loginState = LoginState()
        
        let username = "user@email.com"
        let password = "Test1234"
        let (state, effect) = useCase.receive(
            .credentialInfoInput(username: username, password: password),
            inState: loginState
        )
        XCTAssertEqual(effect, nil)
        XCTAssertEqual(state, LoginState(validEmail: true))
    }
}
