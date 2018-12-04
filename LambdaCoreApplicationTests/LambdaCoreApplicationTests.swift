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
            .credentialInfoInput(userName: username, password: password),
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
            .credentialInfoInput(userName: username, password: password),
            inState: loginState
        )
        let expectedAuthenticationScheme = AuthenticationScheme.password(validCredentials: true)
        XCTAssertEqual(effect, nil)
        XCTAssertEqual(state, LoginState(authenticationScheme: expectedAuthenticationScheme))
    }
    func testWhenEmailUsesSSO() {
        let useCase = LoginUseCase()
        let loginState = LoginState(ssoDomains: ["gmail.com"])
        
        let username = "user@gmail.com"
        let password = ""
        let (state, effect) = useCase.receive(
            .credentialInfoInput(userName: username, password: password),
            inState: loginState
        )
        XCTAssertEqual(effect, nil)
        let expectedLoginState = LoginState(
            authenticationScheme: AuthenticationScheme.sso,
            ssoDomains: ["gmail.com"]
        )
        XCTAssertEqual(state, expectedLoginState)
    }
    func testWhenSSOEmailIsChangedToNonSSOEmail() {
        let useCase = LoginUseCase()
        let loginState = LoginState(authenticationScheme: .sso, ssoDomains: [])
        
        let email = "user@anywhere.com"
        let password = ""
        let (state, effect) = useCase.receive(
            .credentialInfoInput(userName: email, password: password),
            inState: loginState
        )
        let expectedLoginState = LoginState(
            authenticationScheme: AuthenticationScheme.password(validCredentials: false)
        )
        XCTAssertNil(effect)
        XCTAssertEqual(state, expectedLoginState)
    }
}
