//
//  Result.swift
//  Aloha
//
//  Created by Panucci, Julian R on 9/4/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation

public enum Result <T> {
    case success(T)
    case failure(Error)
}
