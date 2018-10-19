//
//  FireURLProtocol.swift
//  FireMock
//
//  Created by BEN HARZALLAH on 04/11/2016.
//  Copyright © 2016 BEN HARZALLAH. All rights reserved.
//

import Foundation
import UIKit

public class FireURLProtocol: URLProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    private var dataTask: URLSessionDataTask?
    
    public static let FireURLProtocolKey: String = "FireURLProtocolKey"
    
    lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = {
            // Use in priority configuration setting if exists.
            if let conf = FireMock.sessionConfiguration {
                return conf
            }
            
            let configuration = URLSessionConfiguration.default
            
            return configuration
        }()
        
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session
    }()
    
    override public class func canInit(with: URLRequest) -> Bool {        
        if let _ = URLProtocol.property(forKey: FireURLProtocol.FireURLProtocolKey, in: with) {
            return false
        }

        return true
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override class func requestIsCacheEquivalent(_ firstRequest: URLRequest, to secondRequest: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(firstRequest, to:secondRequest)
    }
    
    public override func startLoading() {
        guard let url = request.url, let httpMethod = request.httpMethod else { return }

        let configurationMock = FireURLProtocol.findMock(url: url, httpMethod: httpMethod)
        
        if let configMock = configurationMock, FireURLProtocol.canUseMock(url: url), configMock.enabled, FireMock.isEnabled, let mock = configMock.mocks.first {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + mock.afterTime, execute: {
                FireMockDebug.debug(message: "File mock returns for \(url) : \(mock.mockFile())", level: .high)
                do {
                    let data = try mock.readMockFile()
                    let response = HTTPURLResponse(url: url, statusCode: mock.statusCode, httpVersion: mock.httpVersion, headerFields: mock.headers)!
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
                    self.client?.urlProtocol(self, didLoad: data)
                    self.client?.urlProtocolDidFinishLoading(self)
                } catch {
                    self.client?.urlProtocol(self, didFailWithError: error)
                    self.client?.urlProtocolDidFinishLoading(self)
                }
            })
        } else {
            // Else fired normal Request

            let newRequest = (self.request as NSURLRequest).mutableCopy() as! NSMutableURLRequest

            URLProtocol.setProperty(true, forKey: FireURLProtocol.FireURLProtocolKey, in: newRequest)

            self.dataTask = session.dataTask(with: newRequest as URLRequest)
            self.dataTask?.resume()
        }
    }
    
    public override func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }
    
    // URL Session Delegate
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let err = error {
            self.client?.urlProtocol(self, didFailWithError: err)
        } 
        
        self.client?.urlProtocolDidFinishLoading(self)
    }

    // MARK: - Helper
    
    internal static func findMock(url: URL, httpMethod: String) -> FireMock.ConfigMock? {
        let urlComponents = URLComponents(string: url.absoluteString)

        for configMock in FireMock.mocks {
            guard let mock = configMock.mocks.first else { continue }

            let params = mock.parameters ?? []
			switch configMock.mockType {
			case .url(url: let configMockURL):
				// Case where urls absolute string are equals and parameters name from protocol are equals with query items from url req.
				if
					let urlComp = urlComponents,
					let queryItems = urlComp.queryItems,
					params.count == queryItems.count,
                    params.hasSameElements(as: queryItems.map({ $0.name })),
					configMockURL.absoluteStringWithoutQuery == url.absoluteStringWithoutQuery,
					configMock.httpMethod.rawValue == httpMethod {
					return configMock
				}
				// Case where zero parameters exists in two url.
				else if
					let urlComp = urlComponents,
					urlComp.queryItems == nil,
					params.count == 0,
					configMockURL.absoluteString == url.absoluteString,
					configMock.httpMethod.rawValue == httpMethod {
					return configMock
				}
				// case : Url req with params, url mock with params but parameters in protocol is empty.
				else if
					let urlComp = urlComponents,
					let _ = urlComp.queryItems,
					configMockURL == url,
					configMock.httpMethod.rawValue == httpMethod {
					return configMock
				}
			case .regex(regex: let configMockRegex):
				// case : Find if exist with regex.
				if !(search(regex: configMockRegex, in: url.absoluteString).isEmpty),
				configMock.httpMethod.rawValue == httpMethod {
					return configMock
				}
			}
        }

        return nil
    }

    private static func search(regex: String, in str: String) -> [NSTextCheckingResult] {
        do {
            let exp = try NSRegularExpression(pattern: regex)
            return exp.matches(in: str, options: [], range: NSRange(location: 0, length: str.utf16.count))
        } catch {
            return []
        }
    }

    internal static func canUseMock(url: URL) -> Bool {
        if let host = url.host {
            let containsHost = FireMock.onlyHosts.contains(host)
            let excludeHost = FireMock.excludeHosts.contains(host)
            if excludeHost {
                return false
            } else if containsHost || (FireMock.onlyHosts.isEmpty && FireMock.excludeHosts.isEmpty) {
                return true
            } else if !containsHost || excludeHost {
                return false
            } else {
                return true
            }
            
        } else {
            return true
        }
    }
}

fileprivate extension URL {
    var absoluteStringWithoutQuery: String? {
        if let query = query {
            return absoluteString.replacingOccurrences(of: "?" + query, with: "")
        }
        return absoluteString
    }
}

fileprivate extension Array where Element: Comparable {
    func hasSameElements(as other: [Element]) -> Bool {
        return count == other.count && sorted() == other.sorted()
    }
}
