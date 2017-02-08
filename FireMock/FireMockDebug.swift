//
//  FireMockDebug.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 08/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import Foundation

/// Quantity information debug.
public enum FireMockDebugLevel {
    case low
    case high
}

struct FireMockDebug {
    static var prefix: String?
    static var level: FireMockDebugLevel = .high

    static func debug(message: String, level: FireMockDebugLevel) {
        if FireMock.debugIsEnabled, (self.level == level || self.level == .high) {
            print("\(prefix ?? "FireMock ") - \(message)")
        }
    }
}
