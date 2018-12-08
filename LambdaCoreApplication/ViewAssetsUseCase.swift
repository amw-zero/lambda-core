//
//  ViewAssetsUseCase.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/8/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation
import LambdaCoreModel
public struct ViewAssetsState {
    public let assets: [Asset]
    public init(assets: [Asset] = []) {
        self.assets = assets
    }
}

struct ViewAssetsUseCase {
    
}
