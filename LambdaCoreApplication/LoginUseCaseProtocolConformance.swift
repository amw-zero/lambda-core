//
//  LoginUseCaseProtocolConformance.swift
//  LambdaCoreApplication
//
//  Created by Alex Weisberger on 12/4/18.
//  Copyright © 2018 vts. All rights reserved.
//

import Foundation

extension Effect: Equatable where Action: Equatable {
    public static func == (lhs: Effect, rhs: Effect) -> Bool {
        switch (lhs, rhs) {
        case (.viewTransition, .viewTransition):
            return true
        case (
            .httpRequest(let lMethod, let lPath, let lCompletion),
            .httpRequest(let rMethod, let rPath, let rCompletion)
            ):
            return lMethod == rMethod && lPath == rPath && lCompletion("dummy") == rCompletion("dummy")
        case (let .setRootView(lView), let .setRootView(rView)):
            return lView == rView
        case (let .composite(lEffects), let .composite(rEffects)):
            return lEffects == rEffects
        default:
            return false
        }
    }
}
