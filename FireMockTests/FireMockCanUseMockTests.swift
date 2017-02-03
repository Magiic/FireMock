//
//  FireMockCanUseMock.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 03/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import XCTest

@testable import FireMock

/*
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

 FireMock.register(mock: NewsMock.noMatching, forURL: url, httpMethod: .post)
 configMock = FireURLProtocol.findMock(url: urlComplete, httpMethod: MockHTTPMethod.get.rawValue)
 XCTAssertNil(configMock)
 }*/

class FireMockCanUseMockTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        FireMock.onlyHosts = []
        FireMock.excludeHosts = []
        super.tearDown()
    }

    func testHostAllow() {
        FireMock.onlyHosts = ["foo.com"]

        let urlStr = "https://foo.com"
        let url = URL(string: urlStr)!

        var canUse = FireURLProtocol.canUseMock(url: url)
        XCTAssertTrue(canUse)

        FireMock.onlyHosts = []
        canUse = FireURLProtocol.canUseMock(url: url)
        XCTAssertTrue(canUse)
    }

    func testHostNotAllow() {
        FireMock.onlyHosts = ["foo.com"]

        let urlStr = "https://poo.com"
        let url = URL(string: urlStr)!

        let canUse = FireURLProtocol.canUseMock(url: url)
        XCTAssertFalse(canUse)
    }

    func testExcludeHost() {
        FireMock.excludeHosts = ["foo.com"]

        let urlStr = "https://foo.com"
        let url = URL(string: urlStr)!

        var canUse = FireURLProtocol.canUseMock(url: url)
        XCTAssertFalse(canUse)

        FireMock.excludeHosts = []
        canUse = FireURLProtocol.canUseMock(url: url)
        XCTAssertTrue(canUse)
    }
    
    
}
