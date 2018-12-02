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
        XCTAssertEqual(effect, ViewTransition())
        XCTAssertEqual(state, LoginState())
    }
}
