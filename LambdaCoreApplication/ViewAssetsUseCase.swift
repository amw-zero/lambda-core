//
//  ViewAssetsUseCase.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/8/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation
import LambdaCoreModel

public struct ViewAssetsAction {
    
}

public struct ViewAssetsState {
    public let assets: [Asset]
    public init(assets: [Asset] = []) {
        self.assets = assets
    }
}

public struct ViewAssetsUseCase: UseCase {
    public init() {
        
    }
    public func receive(_ action: ViewAssetsAction, inState state: ViewAssetsState) -> (ViewAssetsState, Effect?) {
        return (ViewAssetsState(), nil)
    }
}
