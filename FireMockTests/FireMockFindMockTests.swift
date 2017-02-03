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
        case noMatching

        func mockFile() -> String {
            switch self {
            case .noParams:
                return "noParams.json"
            case .hasParameters:
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

    func testNoneParameters() {
        let urlStr = "https://foo.org/mypath?title=mytitle&content=mycontent"
        let url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.noParams, forURL: url, httpMethod: .get)
        let configMock = FireURLProtocol.findMock(url: url, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNotNil(configMock)
    }

    func testHasParameter() {
        let urlStr = "https://foo.org/mypath?title=mytitle&content=mycontent"
        let url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.noParams, forURL: url, httpMethod: .get)
        let configMock = FireURLProtocol.findMock(url: url, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNotNil(configMock)
    }

    func testParametersNoMatching() {
        let urlStrNotComplete = "https://foo.org/mypath"
        let url = URL(string: urlStrNotComplete)!
        let urlStrComplete = "https://foo.org/mypath?title=mytitle&content=mycontent"
        let urlComplete = URL(string: urlStrComplete)!
        FireMock.register(mock: NewsMock.noMatching, forURL: url, httpMethod: .get)
        var configMock = FireURLProtocol.findMock(url: urlComplete, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNil(configMock)

        FireMock.unregisterAll()
        let urlStrPost = "https://foo.org/mypath"
        let urlPost = URL(string: urlStrPost)!
        FireMock.register(mock: NewsMock.noMatching, forURL: urlPost, httpMethod: .post)
        configMock = FireURLProtocol.findMock(url: urlPost, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNil(configMock)
    }
    
}
