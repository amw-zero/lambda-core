//
//  Asset.swift
//  LambdaCoreModel
//
//  Created by Alex Weisberger on 12/8/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation

public struct Asset: Equatable {
    public let name: String
    public init(name: String) {
        self.name = name
    }
}
