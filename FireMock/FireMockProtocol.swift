//
//  FireMockProtocol.swift
//  FireMock
//
//  Created by BEN HARZALLAH on 18/11/2016.
//  Copyright © 2016 BEN HARZALLAH. All rights reserved.
//

import Foundation

enum MockError: Error {
    case fileNotFound
    case buildDataFailed
}

public protocol FireMockProtocol {
    /// Bundle where file is located
    var bundle: Bundle { get }
    
    /// Specifies delay time before mock returns response. Default is 0.0 means instantly.
    var afterTime: TimeInterval { get }
    
    /// Specifies the name of mock file used.
    func mockFile() -> String
    
}

public extension FireMockProtocol {
    
    var afterTime: TimeInterval { return 0.0 }
    
    /// Read mock from mockFile function specifies in FireMockProtocol. If no extension, json is used to find the file.
    /// - Returns: Data file ou error if file not found.
    func readMockFile() throws -> Data {
        let name = self.mockFile()
        let components = name.components(separatedBy: ".")
        guard let resourceName = components.first else {
            throw MockError.fileNotFound
        }
        
        let extensionName: String
        if let ext = components.last, components.count > 1 {
            extensionName = ext
        } else {
            extensionName = "json"
        }
        
        if let path = bundle.path(forResource: resourceName, ofType: extensionName) {
            let url = URL(fileURLWithPath: path)
            do {
                return try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
            } catch {
                throw MockError.buildDataFailed
            }
        } else {
            throw MockError.fileNotFound
        }
    }
    
}

public struct FireMock {
    
    public struct ConfigMock {
        var mock: FireMockProtocol
        var enabled: Bool = true
        var httpResponse: HTTPURLResponse? = nil
    }
    
    /// Dictionary mocks added.
    private static var mocks: [URL: ConfigMock] = [:]
    
    private(set) static var isEnabled: Bool = false
    
    
    /// Register a FireMockProtocol used for a specific URL when request is fired.
    ///
    /// - Parameters:
    ///   - mock: FireMockProtocol contained file mock will be used.
    ///   - url: URL associated to mock.
    public static func registerMock<T: FireMockProtocol>(mock: T, forURL url: URL, enabled: Bool = true, httpResponse: HTTPURLResponse? = nil) {
        mocks[url] = ConfigMock(mock: mock, enabled: enabled, httpResponse: httpResponse)
    }
    
    /// Unregister a FireMockProtocol for a specific URL.
    ///
    /// - Parameter url: URL associated to mock.
    public static func unregisterMock(forURL url: URL) {
        mocks.removeValue(forKey: url)
    }
    
    /// Unregister all mocks.
    public static func unregisterAllMocks() {
        mocks.removeAll()
    }
    
    public static func allMocks() -> [URL: ConfigMock] {
        return mocks
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
        
        FireMock.isEnabled = enabled
    }
    
    /// Specifies URLSessionConfiguration to use when request if fired.
    public static var sessionConfiguration: URLSessionConfiguration? = nil
    
    /// Specifies hosts where mock can be used. If empty, mock works for all hosts.
    public static var onlyHosts: [String] = []
    
    /// Specifies hosts where mock cannot be used.
    public static var excludeHosts: [String] = []
}


