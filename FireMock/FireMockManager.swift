//
//  FireMockManager.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 08/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import Foundation

public struct FireMock {

    public struct ConfigMock {
        var mocks: [FireMockProtocol]
        var httpMethod: MockHTTPMethod
        var enabled: Bool = true
        var url: URL?
        var regex: String?
    }

    /// Mocks added.
    public private(set) static var mocks: [ConfigMock] = []

    /// Specifies if FireMock is enabled.
    public private(set) static var isEnabled: Bool = false

    /// Specifies if debug information is enabled.
    public private(set) static var debugIsEnabled: Bool = false


    /// Register a FireMockProtocol used for a specific URL when request is fired.
    ///
    /// - Parameters:
    ///   - mock: FireMockProtocol variadic parameter takes 1 or more mock contained file mock will be used.
    ///   - url: URL associated to mock.
    ///   - httpMethod: HTTP Method.
    ///   - enabled: Specifies if mock is used.
    public static func register<T: FireMockProtocol>(mock: T..., forURL url: URL, httpMethod: MockHTTPMethod, enabled: Bool = true) {

        if mock.isEmpty {
            FireMockDebug.debug(message: "Register with an empty mock for \(url)", level: .high)
            return
        }

        // Remove similar mock if existing
        mocks = mocks.filter({ !($0.url == url && $0.httpMethod == httpMethod) })

        let config = ConfigMock(mocks: mock, httpMethod: httpMethod, enabled: enabled, url: url, regex: nil)
        mocks.append(config)

        let names = mock.reduce("", { $0.0 + " " + ($0.1.name ?? "") })
        FireMockDebug.debug(message: "Register mock -\(names)- for \(url)", level: .high)
    }


    /// Register a FireMockProtocol used for a specific regex when request is fired.
    /// This method ignore parameters implemented by FireMockProtocol and it will used if no mock associated with url has been found.
    ///
    /// - Parameters:
    ///   - mock: FireMockProtocol variadic parameter takes 1 or more mock contained file mock will be used.
    ///   - regex: regex used to match with url fired.
    ///   - httpMethod: HTTP Method.
    ///   - enabled: Specifies if mock is used.
    public static func register<T: FireMockProtocol>(mock: T..., regex: String, httpMethod: MockHTTPMethod, enabled: Bool = true) {

        if mock.isEmpty {
            FireMockDebug.debug(message: "Register with an empty mock for \(regex)", level: .high)
            return
        }

        // Remove similar mock if existing
        mocks = mocks.filter({ !($0.regex == regex && $0.httpMethod == httpMethod) })
        
        let config = ConfigMock(mocks: mock, httpMethod: httpMethod, enabled: enabled, url: nil, regex: regex)
        mocks.append(config)

        let names = mock.reduce("", { $0.0 + " " + ($0.1.name ?? "") })
        FireMockDebug.debug(message: "Register mock -\(names)- for regex \(regex)", level: .high)
    }

    /// Unregister a FireMockProtocol for a specific URL.
    ///
    /// - Parameter url: URL associated to mock.
    ///   - httpMethod: HTTP Method.
    public static func unregister(forURL url: URL, httpMethod: MockHTTPMethod) {
        mocks = mocks.filter({ !($0.url == url && $0.httpMethod == httpMethod) })
        FireMockDebug.debug(message: "Unregister mock for \(url)", level: .high)
    }


    /// Unregister a FireMockProtocol for a specific regex.
    ///
    /// - Parameters:
    ///   - regex: regex associated to mock
    ///   - httpMethod: HTTP Method.
    public static func unregister(regex: String, httpMethod: MockHTTPMethod) {
        mocks = mocks.filter({ !($0.regex == regex && $0.httpMethod == httpMethod) })
        FireMockDebug.debug(message: "Unregister mock for regex \(regex)", level: .high)
    }

    /// Unregister all mocks.
    public static func unregisterAll() {
        mocks.removeAll()
        FireMockDebug.debug(message: "Unregister all mocks", level: .high)
    }

    internal static func update(configMock: ConfigMock) {
        mocks = mocks.filter({
            !($0.url == configMock.url && $0.httpMethod == configMock.httpMethod) ||
                !($0.regex == configMock.regex && $0.httpMethod == configMock.httpMethod) })
        mocks.append(configMock)

        let names = configMock.mocks.reduce("", { $0.0 + " " + ($0.1.name ?? "") })
        FireMockDebug.debug(message: "Update mock -\(names)- for \(configMock.url)", level: .high)
    }

    /// Enabled FireMock.
    ///
    /// - Parameter enabled: Enabled Mock in application.
    public static func enabled(_ enabled: Bool) {
        if enabled {
            URLProtocol.registerClass(FireURLProtocol.self)
        } else {
            URLProtocol.unregisterClass(FireURLProtocol.self)
        }

        let text = enabled ? "FireMock is turn on" : "FireMock is turn off"
        FireMockDebug.debug(message: text, level: .low)

        FireMock.isEnabled = enabled
    }

    /// Enabled FireMock for specific configuration.
    ///
    /// - Parameter enabled: Enabled Mock in application.
    /// - Parameter URL Session configuration where FireMock need to be enable.
    internal static func enabled(_ enabled: Bool, forConfiguration config: URLSessionConfiguration) {
        if enabled, let protocolClasses = config.protocolClasses, !(protocolClasses.contains(where: { $0 is FireURLProtocol.Type })) {
            config.protocolClasses?.insert(FireURLProtocol.self as AnyClass, at: 0)
        } else if !enabled, config.protocolClasses?.first is FireURLProtocol.Type {
            config.protocolClasses?.remove(at: 0)
        }

        FireMock.enabled(enabled)

        let text = enabled ? "FireMock is turn on for configuration \(config)" : "FireMock is turn off for configuration \(config)"
        FireMockDebug.debug(message: text, level: .low)

    }

    /// Specifies if FireMock is enabled for specific URLSessionConfiguration.
    public static func isEnabled(forConfiguration config: URLSessionConfiguration) -> Bool {
        if let protocolClasses = config.protocolClasses, protocolClasses.contains(where: { $0 is FireURLProtocol.Type }) {
            return true
        } else {
            return false
        }
    }

    /// Specifies URLSessionConfiguration to use when request if fired.
    public static var sessionConfiguration: URLSessionConfiguration? = nil

    /// Specifies hosts where mock can be used. If empty, mock works for all hosts.
    public static var onlyHosts: [String] = []

    /// Specifies hosts where mock cannot be used.
    public static var excludeHosts: [String] = []

    /// Present a default ViewController where are all mocks register by application in compile time.
    /// You can enabled or disabled any register mock on runtime.
    public static func presentMockRegisters(from: UIViewController, backTapped: ( () -> Void )?) {
        let mockController = FireMockViewController(nibName: "FireMockViewController", bundle: Bundle(for: FireMockViewController.self))
        mockController.backTapped = backTapped
        let navController = UINavigationController(rootViewController: mockController)
        from.present(navController, animated: true, completion: nil)
    }

    /// Debug information.
    public static func debug(enabled: Bool, prefix: String? = nil, level: FireMockDebugLevel = .high) {
        debugIsEnabled = enabled
        FireMockDebug.level = level
        FireMockDebug.prefix = prefix
    }
}

func ==(lhs: FireMock.ConfigMock, rhs: FireMock.ConfigMock) -> Bool {
    return lhs.url == rhs.url && rhs.httpMethod == lhs.httpMethod
}
