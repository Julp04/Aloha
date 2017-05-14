//
//  Error.swift
//  QNect
//
//  Created by Panucci, Julian R on 5/14/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation


//A cool way to make errors

public enum Oops: Error {
    case customError(String)
}

extension Oops: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .customError(let description):
            return NSLocalizedString(description, comment: "")
        }
    }
}
