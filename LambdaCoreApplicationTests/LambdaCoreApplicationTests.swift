//
//  LambdaCoreApplicationTests.swift
//  LambdaCoreApplicationTests
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import XCTest
@testable import LambdaCoreModel
@testable import LambdaCoreApplication
class LambdaCoreApplicationTests: XCTestCase {
    var useCase: LoginUseCase!
    var loginState: LoginState!
    override func setUp() {
        useCase = LoginUseCase()
        loginState = LoginState()
    }
    func testWhenUserIsNotLoggedIn() {
        let (state, effect) = useCase.receive(.initiateLogin, inState: loginState)
        let request = Effect.httpRequest(
            method: "get",
            path: "api/sso_domains",
            completion: { LoginAction.ssoDomainsReceived([$0]) }
        )
        let setRootView = Effect.setRootView(view: .login)
        let expectedEffect = Effect.composite([request, setRootView])
        guard let efct = effect else {
            XCTFail("Expected effect was not returned")
            return
        }
        XCTAssertEqual(efct, expectedEffect)
        XCTAssertEqual(state, LoginState())
    }
    func testWhenSSODomainsAreReturned() {
        let (state, effect) = useCase.receive(LoginAction.ssoDomainsReceived(["test@sso.com"]), inState: loginState)
        XCTAssertNil(effect)
        XCTAssertEqual(state.ssoDomains, ["test@sso.com"])
    }
    func testWhenNonSSOEmailAndPasswordAreNotInput() {
        let username = ""
        let password = ""
        let (state, effect) = useCase.receive(
            .credentialInfoInput(userName: username, password: password),
            inState: loginState
        )
        XCTAssertNil(effect)
        XCTAssertEqual(state, LoginState())
    }
    func testWhenValidNonSSOEmailAndPasswordAreInput() {
        let username = "user@email.com"
        let password = "Test1234"
        let (state, effect) = useCase.receive(
            .credentialInfoInput(userName: username, password: password),
            inState: loginState
        )
        let expectedAuthenticationScheme = AuthenticationScheme.password(validCredentials: true)
        XCTAssertNil(effect)
        XCTAssertEqual(state, LoginState(authenticationScheme: expectedAuthenticationScheme))
    }
    func testWhenEmailUsesSSO() {
        let loginState = LoginState(ssoDomains: ["gmail.com"])
        let username = "user@gmail.com"
        let password = ""
        let (state, effect) = useCase.receive(
            .credentialInfoInput(userName: username, password: password),
            inState: loginState
        )
        XCTAssertNil(effect)
        let expectedLoginState = LoginState(
            authenticationScheme: AuthenticationScheme.sso,
            ssoDomains: ["gmail.com"]
        )
        XCTAssertEqual(state, expectedLoginState)
    }
    func testWhenSSOEmailIsChangedToNonSSOEmail() {
        let loginState = LoginState(ssoDomains: [])
        
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
    func testWhenLoginButtonIsPressedAndLoginSucceeds() {
        let userName = "user@email.com"
        let password = "Password123"
        let loginAction = LoginAction.attemptLogin(withUserName: userName, andPassword: password)
        let (state, effect) = useCase.receive(loginAction, inState: loginState)
        let loginRequest = Effect.httpRequest(
            method: "get",
            path: "/api/sign_in",
            completion: { .loginSucceeded(forUser: UserParser.user(from: $0)) }
        )
        guard let efct = effect else {
            XCTFail("Expected effect was not produced")
            return
        }
        XCTAssertEqual(efct, loginRequest)
        XCTAssertEqual(state, loginState)
    }
    func testWhenLoginSucceeds() {
        let user = User(email: "email.com")
        let (state, effect) = useCase.receive(.loginSucceeded(forUser: user), inState: loginState)
        guard let efct = effect else {
            XCTFail("Expected effect was not returned")
            return
        }
        XCTAssertEqual(efct, .setRootView(view: .home))
        XCTAssertEqual(state, loginState)
    }
}
