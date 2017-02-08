//
//  Utils.swift
//  FireMock
//
//  Created by Haithem Ben harzallah on 08/02/2017.
//  Copyright © 2017 haithembenharzallah. All rights reserved.
//

import Foundation

enum MockError: Error {
    case fileNotFound
    case buildDataFailed
}

public enum MockHTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case options = "OPTIONS"
    case head    = "HEAD"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}
