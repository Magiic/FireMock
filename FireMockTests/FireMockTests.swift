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

        var bundle: Bundle {
            return Bundle(for: FireMockProtocolTests.self)
        }
        
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
        XCTAssertFalse(FireMock.isEnabled)
        FireMock.enabled(true)
        XCTAssertTrue(FireMock.isEnabled)

        FireMock.enabled(false)
        let conf = URLSessionConfiguration.default
        XCTAssertFalse(FireMock.isEnabled(forConfiguration: conf))
        FireMock.enabled(true, forConfiguration: conf)
        XCTAssertTrue(FireMock.isEnabled)
        XCTAssertTrue(FireMock.isEnabled(forConfiguration: conf))

        FireMock.enabled(false)
        XCTAssertFalse(FireMock.isEnabled)
    }

    func testRegister() {
        let urlStr = "https://foo.org/mypath?title=mytitle&content=mycontent"
        let url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.hasParameters, forURL: url, httpMethod: .get)
        let configMock = FireURLProtocol.findMock(url: url, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNotNil(configMock)

        // No duplicate
        FireMock.register(mock: NewsMock.hasParameters, forURL: url, httpMethod: .get)
        XCTAssertEqual(FireMock.mocks.count, 1)
    }

    func testRegisterRegex() {
        let urlStr = "https://foo.org/path1/10/path3?title=mytitle&content=mycontent"
        var regex = "https?://foo.org/[a-zA-Z0-9\\.-]+/[0-9](/\\S*)?"
        let url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.hasParameters, regex: regex, httpMethod: .get)
        let configMock = FireURLProtocol.findMock(url: url, httpMethod: MockHTTPMethod.get.rawValue)
        XCTAssertNotNil(configMock)

        // No duplicate
        FireMock.register(mock: NewsMock.hasParameters, regex: regex, httpMethod: .get)
        XCTAssertEqual(FireMock.mocks.count, 1)

        // Multiple regex
        regex = "https?://fee.org/[a-zA-Z0-9\\.-]+/[0-9](/\\S*)?"
        FireMock.register(mock: NewsMock.hasParameters, regex: regex, httpMethod: .get)
        XCTAssertEqual(FireMock.mocks.count, 2)

        FireMock.register(mock: NewsMock.hasParameters, regex: regex, httpMethod: .post)
        XCTAssertEqual(FireMock.mocks.count, 3)
    }

    func testUnRegister() {
        let urlStr = "https://foo.org/mypath?title=mytitle&content=mycontent"
        let url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.hasParameters, forURL: url, httpMethod: .get)
        FireMock.unregister(forURL: url, httpMethod: .get)
        XCTAssertTrue(FireMock.mocks.isEmpty)
    }

    func testUnRegisterRegex() {
        let regex = "https?://foo.org/[a-zA-Z0-9\\.-]+/[0-9](/\\S*)?"
        FireMock.register(mock: NewsMock.hasParameters, regex: regex, httpMethod: .get)
        FireMock.unregister(regex: regex, httpMethod: .get)
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

    func testUpdateMock() {
        let urlStr = "https://foo.org/mypath?title=mytitle&content=mycontent"
        let url = URL(string: urlStr)!
        FireMock.register(mock: NewsMock.hasParameters, forURL: url, httpMethod: .get)
        XCTAssertEqual(FireMock.mocks.count, 1)
        var configMock = FireMock.mocks[0]
        configMock.enabled = false
        FireMock.update(configMock: configMock)
        XCTAssertEqual(FireMock.mocks.count, 1)
        configMock = FireMock.mocks[0]
        XCTAssertFalse(configMock.enabled)
    }

    func testMockViewController() {
        let controller = FireMockViewController(nibName: "FireMockViewController", bundle: Bundle(for: FireMockViewController.self))
        controller.view.backgroundColor = .white
        XCTAssertNotNil(controller)

        XCTAssertFalse(FireMock.isEnabled)
        XCTAssertFalse(controller.enabledFireMock.isOn)
    }
    
}
