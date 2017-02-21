//
//  URLSessionConfigurationExtension.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 18/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import Foundation

internal private(set) var defaultSessionConf: URLSessionConfiguration?
internal private(set) var ephemeralSessionConf: URLSessionConfiguration?

private let swizzling: (AnyClass, Selector, Selector) -> Void = { forClass, originalSelector, swizzledSelector in
    let originalMethod = class_getClassMethod(forClass, originalSelector)
    let swizzledMethod = class_getClassMethod(forClass, swizzledSelector)
    let origImplementation = method_getImplementation(originalMethod)
    let newImplementation = method_getImplementation(swizzledMethod)

    method_exchangeImplementations(originalMethod, swizzledMethod)
}

extension URLSessionConfiguration {

    open override class func initialize() {

        guard self === URLSessionConfiguration.self else { return }

        let originalDefault = #selector(getter: self.default)
        let swizzledDefault = #selector(getter: swizzled_default)

        let originalEphemeral = #selector(getter: self.ephemeral)
        let swizzledEphemeral = #selector(getter: swizzled_ephemeral)

        swizzling(self, originalDefault, swizzledDefault)
        swizzling(self, originalEphemeral, swizzledEphemeral)
    }

    dynamic fileprivate class var swizzled_default: URLSessionConfiguration {
        get {
            let conf = self.swizzled_default
            defaultSessionConf = conf
            FireMock.enabled(FireMock.isEnabled, forConfiguration: conf)

            return conf
        }
    }

    dynamic fileprivate class var swizzled_ephemeral: URLSessionConfiguration {
        get {
            let conf = self.swizzled_ephemeral
            ephemeralSessionConf = conf
            FireMock.enabled(FireMock.isEnabled, forConfiguration: conf)

            return conf
        }
    }

}
