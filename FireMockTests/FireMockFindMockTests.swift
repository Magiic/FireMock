//
//  FireMockFindMockTests.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 04/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import XCTest

@testable import FireMock

class FireMockFindMockTests: XCTestCase {
    
    struct News {
        var title: String
        var content: String
    }

    enum NewsMock: FireMockProtocol {
        case noParams
        case hasParameters
        case hasOneParameter
        case noMatching

        var bundle: Bundle {
            return Bundle(for: FireMockProtocolTests.self)
        }

        func mockFile() -> String {
            switch self {
            case .noParams:
                return "noParams.json"
            case .hasParameters, .hasOneParameter:
                return "test.json"
            case .noMatching:
                return "noMatching.json"
            }
        }

        var parameters: [String]? {
            switch self {
            case .noParams:
                return nil
            case .hasParameters:
                return ["title", "content"]
            case .hasOneParameter:
                return ["title"]
            case .noMatching:
                return ["foo", "fee"]
            }
        }

    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        FireMock.unregisterAll()
        super.tearDown()
    }

    func testAbsoluteUrlNoMatching() {
        let urlStrNotComplete = "https://foo.org/mypath?title=mytitle&content=mycontent"
        let url = URL(string: urlStrNotComplete)!
        let urlStrComplete = "https://foo.org/musecondpath?title=mytitle&content=mycontent"
        let urlComplete = URL(string: urlStrComplete)!
        FireMock.register(mock: NewsMock.hasParameters, forURL: url, httpMethod: .get)
        let configMock = FireURLProtocol.findMock(url: urlComplete, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNil(configMock)
    }

    func testZeroParameters() {
        let urlStr = "https://foo.org/mypath"
        let url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.noParams, forURL: url, httpMethod: .get)
        let configMock = FireURLProtocol.findMock(url: url, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNotNil(configMock)
    }

    func testHasParameter() {
        var urlStr = "https://foo.org/mypath?title=mytitle&content=mycontent"
        var url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.hasParameters, forURL: url, httpMethod: .get)
        var configMock = FireURLProtocol.findMock(url: url, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNotNil(configMock)

        FireMock.unregisterAll()
        FireMock.register(mock: NewsMock.noParams, forURL: url, httpMethod: .get)
        XCTAssertNotNil(configMock)

        FireMock.unregisterAll()
        urlStr = "https://foo.org/mypath"
        url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.hasOneParameter, forURL: url, httpMethod: .get)
        urlStr = "https://foo.org/mypath?title=mytitle"
        url = URL(string: urlStr)!
        configMock = FireURLProtocol.findMock(url: url, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNotNil(configMock)
    }

    func testParametersNoMatching() {
        var urlStrRegister = "https://foo.org/mypath"
        var urlRegister = URL(string: urlStrRegister)!
        var urlRequestStr = "https://foo.org/mypath?title=mytitle&content=mycontent"
        var urlRequest = URL(string: urlRequestStr)!
        FireMock.register(mock: NewsMock.noMatching, forURL: urlRegister, httpMethod: .get)
        var configMock = FireURLProtocol.findMock(url: urlRequest, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNil(configMock)

        FireMock.unregisterAll()
        urlStrRegister = "https://foo.org/mypath?title=mytitle&content=mycontent"
        urlRegister = URL(string: urlStrRegister)!
        urlRequestStr = "https://foo.org/mypath"
        urlRequest = URL(string: urlRequestStr)!
        FireMock.register(mock: NewsMock.noParams, forURL: urlRegister, httpMethod: .get)
        configMock = FireURLProtocol.findMock(url: urlRequest, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNil(configMock)

        FireMock.unregisterAll()
        let urlStrPost = "https://foo.org/mypath"
        let urlPost = URL(string: urlStrPost)!
        FireMock.register(mock: NewsMock.noMatching, forURL: urlPost, httpMethod: .post)
        configMock = FireURLProtocol.findMock(url: urlPost, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNil(configMock)
    }

    func testRegex() {
        // Matching
        var urlStr = "https://foo.org/path1/10/path3?title=mytitle&content=mycontent"
        var regex = "https?://foo.org/[a-zA-Z0-9\\.-]+/[0-9](/\\S*)?"
        var url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.hasParameters, regex: regex, httpMethod: .get)
        var configMock = FireURLProtocol.findMock(url: url, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNotNil(configMock)

        // Path not matching
        FireMock.unregisterAll()
        urlStr = "https://foo.org/path1/test/path3?title=mytitle&content=mycontent"
        url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.hasParameters, regex: regex, httpMethod: .get)
        configMock = FireURLProtocol.findMock(url: url, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNil(configMock)

        // Method HTTP not matching
        FireMock.unregisterAll()
        urlStr = "https://foo.org/path1/10/path3?title=mytitle&content=mycontent"
        url = URL(string: urlStr)!
        regex = "https?://foo.org/[a-zA-Z0-9\\.-]+/[0-9](/\\S*)?"
        FireMock.register(mock: NewsMock.hasParameters, regex: regex, httpMethod: .get)
        configMock = FireURLProtocol.findMock(url: url, httpMethod: MockHTTPMethod.post.rawValue)
        XCTAssertNil(configMock)
    }
    
}
