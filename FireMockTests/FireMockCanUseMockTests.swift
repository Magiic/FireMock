//
//  FireMockCanUseMock.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 03/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import XCTest

@testable import FireMock

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
