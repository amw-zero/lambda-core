//
//  ViewAssetsUseCaseTests.swift
//  LambdaCoreApplicationTests
//
//  Created by Alex Weisberger on 12/9/18.
//  Copyright © 2018 vts. All rights reserved.
//

import XCTest
import LambdaCoreModel
@testable import LambdaCoreApplication

class ViewAssetsUseCaseTests: XCTestCase {
    var useCase: ViewAssetsUseCase!
    var viewAssetsState: ViewAssetsState!
    override func setUp() {
        super.setUp()
        useCase = ViewAssetsUseCase()
        viewAssetsState = ViewAssetsState()
    }
    func testWhenInitiatedFetchesAssets() {
        let (state, effect) = useCase.receive(.initiate, inState: viewAssetsState)
        guard let efct = effect else {
            XCTFail("Expected effect was not returned")
            return
        }
        let expectedAssets = [Asset(name: "Test Asset")]
        let expectedEffect = Effect<ViewAssetsAction>.httpRequest(
            method: "get",
            path: "api/assets",
            completion: { _ in .assetsReceived(expectedAssets) }
        )
        XCTAssertEqual(efct, expectedEffect)
        XCTAssertEqual(state, ViewAssetsState(assets: [], isFetching: true))
    }
}
