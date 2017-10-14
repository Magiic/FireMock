//
//  FireMockManager.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 08/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import Foundation

public struct FireMock {

	public struct ConfigMock: Equatable {
		
		public enum ConfigMockType: Equatable {
			case url(url: URL)
			case regex(regex: String)
			
			public static func ==(lhs: ConfigMockType, rhs: ConfigMockType) -> Bool {
				switch (lhs, rhs) {
				case (.url(url: let lhsURL), .url(url: let rhsURL)):
					return lhsURL == rhsURL
				case (.regex(regex: let lhsRegex), .regex(regex: let rhsRegex)):
					return lhsRegex == rhsRegex
				default:
					return false
				}
			}
			
			var debugDescription: String {
				switch self {
				case .regex(regex: let regex):
					return regex
				case .url(url: let url):
					return "\(url)"
				}
			}
		}
		
        var mocks: [FireMockProtocol]
        var httpMethod: MockHTTPMethod
        var enabled: Bool = true
		var mockType: ConfigMockType
		
		public init(regex: String, mocks: [FireMockProtocol], httpMethod: MockHTTPMethod, enabled: Bool = true) {
			self.mocks = mocks
			self.httpMethod = httpMethod
			self.enabled = enabled
			self.mockType = ConfigMockType.regex(regex: regex)
		}
		
		public init(url: URL, mocks: [FireMockProtocol], httpMethod: MockHTTPMethod, enabled: Bool = true) {
			self.mocks = mocks
			self.httpMethod = httpMethod
			self.enabled = enabled
			self.mockType = ConfigMockType.url(url: url)
		}
		
		public static func ==(lhs: ConfigMock, rhs: ConfigMock) -> Bool {
			return lhs.httpMethod == rhs.httpMethod && lhs.mockType == rhs.mockType
		}
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
        mocks = mocks.filter({ !($0.mockType == ConfigMock.ConfigMockType.url(url: url) && $0.httpMethod == httpMethod) })

        let config = ConfigMock(url: url, mocks: mock, httpMethod: httpMethod, enabled: enabled)
        mocks.append(config)

        let names = mock.reduce("", { $0 + " " + ($1.name ?? "") })
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
        mocks = mocks.filter({ !($0.mockType == ConfigMock.ConfigMockType.regex(regex: regex) && $0.httpMethod == httpMethod) })
        
        let config = ConfigMock(regex: regex, mocks: mock, httpMethod: httpMethod, enabled: enabled)
        mocks.append(config)

        let names = mock.reduce("", { $0 + " " + ($1.name ?? "") })
        FireMockDebug.debug(message: "Register mock -\(names)- for regex \(regex)", level: .high)
    }

    /// Unregister a FireMockProtocol for a specific URL.
    ///
    /// - Parameter url: URL associated to mock.
    ///   - httpMethod: HTTP Method.
    public static func unregister(forURL url: URL, httpMethod: MockHTTPMethod) {
        mocks = mocks.filter({ !($0.mockType == ConfigMock.ConfigMockType.url(url: url) && $0.httpMethod == httpMethod) })
        FireMockDebug.debug(message: "Unregister mock for \(url)", level: .high)
    }


    /// Unregister a FireMockProtocol for a specific regex.
    ///
    /// - Parameters:
    ///   - regex: regex associated to mock
    ///   - httpMethod: HTTP Method.
    public static func unregister(regex: String, httpMethod: MockHTTPMethod) {
        mocks = mocks.filter({ !($0.mockType == ConfigMock.ConfigMockType.regex(regex: regex) && $0.httpMethod == httpMethod) })
        FireMockDebug.debug(message: "Unregister mock for regex \(regex)", level: .high)
    }

    /// Unregister all mocks.
    public static func unregisterAll() {
        mocks.removeAll()
        FireMockDebug.debug(message: "Unregister all mocks", level: .high)
    }

    internal static func update(configMock: ConfigMock) {
		
		if let index = mocks.index(of: configMock) { // Maintain order of ConfigMocks as they were added
			mocks = mocks.filter({ $0 != configMock })
			mocks.insert(configMock, at: index)
		} else {
			// This Shouldn't be able to happen but recover anyway
			mocks.append(configMock)
		}

        let names = configMock.mocks.reduce("", { $0 + " " + ($1.name ?? "") })
        FireMockDebug.debug(message: "Update mock -\(names)- for \(configMock.mockType.debugDescription)", level: .high)
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
