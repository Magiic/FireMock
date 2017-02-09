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
        var mock: FireMockProtocol
        var httpMethod: MockHTTPMethod
        var enabled: Bool = true
        var url: URL
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
    ///   - mock: FireMockProtocol contained file mock will be used.
    ///   - url: URL associated to mock.
    public static func register<T: FireMockProtocol>(mock: T, forURL url: URL, httpMethod: MockHTTPMethod, enabled: Bool = true) {

        // Remove similar mock if existing
        mocks = mocks.filter({ !($0.url == url && $0.httpMethod == httpMethod) })

        let config = ConfigMock(mock: mock, httpMethod: httpMethod, enabled: enabled, url: url)
        mocks.append(config)

        FireMockDebug.debug(message: "Register mock -\(mock.name)- for \(url)", level: .high)
    }

    /// Unregister a FireMockProtocol for a specific URL.
    ///
    /// - Parameter url: URL associated to mock.
    public static func unregister(forURL url: URL, httpMethod: MockHTTPMethod) {
        mocks = mocks.filter({ !($0.url == url && $0.httpMethod == httpMethod) })
        FireMockDebug.debug(message: "Unregister mock for \(url)", level: .high)
    }

    /// Unregister all mocks.
    public static func unregisterAll() {
        mocks.removeAll()
        FireMockDebug.debug(message: "Unregister all mocks", level: .high)
    }

    internal static func update(configMock: ConfigMock) {
        mocks = mocks.filter({ !($0.url == configMock.url && $0.httpMethod == configMock.httpMethod) })
        mocks.append(configMock)
        FireMockDebug.debug(message: "Update mock -\(configMock.mock.name)- for \(configMock.url)", level: .high)
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
        from.present(mockController, animated: true, completion: nil)
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
