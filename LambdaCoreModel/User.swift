//
//  User.swift
//  LambdaCoreModel
//
//  Created by Alex Weisberger on 12/1/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation
public struct User: Equatable {
    public let email: String
    public init(email: String) {
        self.email = email
    }
}
