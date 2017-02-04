//
//  FireMockTests.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 04/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import XCTest

@testable import FireMock

class FireMockTests: XCTestCase {

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
    
    func testFireMockEnabled() {
        FireMock.enabled(true)
        XCTAssertTrue(FireMock.isEnabled)

        FireMock.enabled(false)
        XCTAssertFalse(FireMock.isEnabled)
    }

    func testRegister() {
        let urlStr = "https://foo.org/mypath?title=mytitle&content=mycontent"
        let url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.hasParameters, forURL: url, httpMethod: .get)
        let configMock = FireURLProtocol.findMock(url: url, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNotNil(configMock)
    }

    func testUnRegister() {
        let urlStr = "https://foo.org/mypath?title=mytitle&content=mycontent"
        let url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.hasParameters, forURL: url, httpMethod: .get)
        FireMock.unregister(forURL: url, httpMethod: .get)
        XCTAssertTrue(FireMock.mocks.isEmpty)
    }

    func testUnRegisterAll() {
        let urlStr = "https://foo.org/mypath?title=mytitle&content=mycontent"
        let url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.hasParameters, forURL: url, httpMethod: .get)
        FireMock.register(mock: NewsMock.hasParameters, forURL: url, httpMethod: .post)
        XCTAssertEqual(FireMock.mocks.count, 2)
        FireMock.unregisterAll()
        XCTAssertTrue(FireMock.mocks.isEmpty)
    }
    
}
