//
//  FireMockProtocolTests.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 08/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import XCTest

@testable import FireMock

class FireMockProtocolTests: XCTestCase {

    struct News {
        var title: String
        var content: String
    }

    enum NewsMock: FireMockProtocol {
        case successFill

        var bundle: Bundle {
            return Bundle(for: FireMockProtocolTests.self)
        }

        func mockFile() -> String {
            switch self {
            case .successFill:
                return "firemock-news.json"
            }
        }

        var headers: [String : String]? {
            return [
                "Content-Type": "application/json",
                "MyKey": "MyValue"
            ]
        }

        var parameters: [String]? {
            switch self {
            case .successFill:
                return ["title", "content"]
            }
        }
        
    }
    
    override func setUp() {
        super.setUp()

        FireMock.enabled(true)
    }
    
    override func tearDown() {
        FireMock.unregisterAll()
        FireMock.enabled(false)
        super.tearDown()
    }
    
    func testParseMock() {
        let expect = expectation(description: "Parse mock file")
        let urlStr = "https://foo.org/mypath?title=mytitle&content=mycontent"
        let url = URL(string: urlStr)!

        FireMock.register(mock: NewsMock.successFill, forURL: url, httpMethod: .get)

        let session = URLSession.shared
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30.0)
        req.httpMethod = MockHTTPMethod.get.rawValue
        session.dataTask(with: req) { data, response, error in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            if let httpResponse = response as? HTTPURLResponse {
                let mock = NewsMock.successFill
                if let headerMock = mock.headers, let headers = httpResponse.allHeaderFields as? [String: String] {
                    XCTAssertEqual(headerMock, headers)
                }
                let code = httpResponse.statusCode
                XCTAssertEqual(code, mock.statusCode)
            } else {
                XCTFail()
            }

            if let d = data, let json = self.json(from: d), let news = json["news"] as? [[String: String]] {
                XCTAssertEqual(news.count, 2)
                for n in news {
                    if let title = n["title"], let content = n["content"] {
                        XCTAssertEqual(title, "My super title")
                        XCTAssertEqual(content, "My great content")
                    } else {
                        XCTFail()
                    }
                }
            } else {
                XCTFail()
            }
            expect.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testNotUseMock() {
        let expect = expectation(description: "Fire request without pass by mock")
        let urlStr = "https://httpbin.org/get"
        let url = URL(string: urlStr)!

        FireMock.register(mock: NewsMock.successFill, forURL: url, httpMethod: .get, enabled: false)

        let session = URLSession.shared
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30.0)
        req.httpMethod = MockHTTPMethod.get.rawValue
        session.dataTask(with: req) { data, response, error in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            if let d = data, let json = self.json(from: d), let urlFound = json["url"] as? String{
                XCTAssertEqual(urlFound, urlStr)
            } else {
                XCTFail()
            }
            expect.fulfill()
            }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    // MARK: - Helper

    private func json(from data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            return nil
        }
    }
    
}
