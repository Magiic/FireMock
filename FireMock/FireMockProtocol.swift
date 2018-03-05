//
//  FireMockProtocol.swift
//  FireMock
//
//  Created by BEN HARZALLAH on 18/11/2016.
//  Copyright © 2016 BEN HARZALLAH. All rights reserved.
//

import Foundation

public protocol FireMockProtocol {
    /// Bundle where file is located
    var bundle: Bundle { get }

    /// Specifies delay time before mock returns response. Default is 0.0 means instantly.
    var afterTime: TimeInterval { get }

    /// Specifies parameters name matching with url.
    var parameters: [String]? { get }

    /// Specifies headers fields returns from HTTPURLResponse. Default is nil.
    var headers: [String: String]? { get }

    /// Specifies version HTTP returns from HTTPURLResponse. Default is 1.1.
    var httpVersion: String? { get }

    /// Specifies status code returns from HTTPURLResponse. Default is 200.
    var statusCode: Int { get }

    /// Specifies category mock. Appear as a header in view list mock.
    var category: String? { get }

    /// Specifies name mock. Appear in view list mock.
    var name: String? { get }

    /// Specifies the name of mock file used.
    func mockFile() -> String

}

public extension FireMockProtocol {

    var afterTime: TimeInterval { return 0.0 }

    var bundle: Bundle { return Bundle.main }

    var parameters: [String]? { return nil }

    var headers: [String: String]? { return nil }

    var httpVersion: String? { return "1.1" }

    var statusCode: Int { return 200 }

    var category: String? { return "CATEGORY NOT DEFINED" }

    var name: String? { return nil }

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
