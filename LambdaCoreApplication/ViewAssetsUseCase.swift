//
//  ViewAssetsUseCase.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/8/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation
import LambdaCoreModel

public enum ViewAssetsAction: Equatable {
    case initiate
    case assetsReceived([Asset])
}

public struct ViewAssetsState: Equatable {
    public let assets: [Asset]
    public let isFetching: Bool
    public init(assets: [Asset] = [], isFetching: Bool = false) {
        self.assets = assets
        self.isFetching = false
    }
}

public struct ViewAssetsUseCase: UseCase {
    public init() {
        
    }
    public func receive(_ action: ViewAssetsAction, inState state: ViewAssetsState) -> (ViewAssetsState, Effect<ViewAssetsAction>?) {
        return (ViewAssetsState(), nil)
    }
}
