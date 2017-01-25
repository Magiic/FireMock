//
//  FireURLProtocol.swift
//  FireMock
//
//  Created by BEN HARZALLAH on 04/11/2016.
//  Copyright © 2016 BEN HARZALLAH. All rights reserved.
//

import UIKit
import Foundation


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

        if
        let configMock = FireMock.mocks.filter({ $0.url == url && $0.httpMethod.rawValue == httpMethod}).last, canUseMock(url: url), configMock.enabled, httpMethod == configMock.httpMethod.rawValue {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + configMock.mock.afterTime, execute: {
                do {
                    let data = try configMock.mock.readMockFile()
                    let response = configMock.httpResponse ?? HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
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
            let newRequest: NSMutableURLRequest = NSMutableURLRequest(url: url, cachePolicy: request.cachePolicy, timeoutInterval: request.timeoutInterval)
            
            let _ = URLProtocol.setProperty(true, forKey: FireURLProtocol.FireURLProtocolKey, in: newRequest)
            
            self.dataTask = session.dataTask(with: request)
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
        } else if let response = task.response {
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        self.client?.urlProtocolDidFinishLoading(self)
    }
}

fileprivate extension FireURLProtocol {
    fileprivate func canUseMock(url: URL) -> Bool {
        let hostCondition: Bool
        
        if let host = url.host {
            hostCondition = FireMock.onlyHosts.contains(host) || !(FireMock.excludeHosts.contains(host))
        } else {
            hostCondition = true
        }
        
        let useMock = FireMock.onlyHosts.isEmpty || hostCondition
        
        return useMock
        
    }
    
    fileprivate func validateCondition(predicates: [NSPredicate], for url: URL) -> Bool {
        if predicates.isEmpty {
            return true
        }
        
        let multiplePredicates = NSCompoundPredicate(type: .and, subpredicates: predicates)
        return multiplePredicates.evaluate(with: url.absoluteString)
    }
}
