# FireMock
FireMock help to stub HTTP requests. If you are looking for an easy way to test your request or work with your server which is not ready so you are in a good place. Test your apps with fake response data and files with a short effort.
With a short code you can set multiple mock and switch from them on runtime with a custom view provide by FireMock.

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/FireMock.svg)](https://img.shields.io/cocoapods/v/FireMock.svg)
[![Platform](https://img.shields.io/cocoapods/p/FireMock.svg?style=flat)](http://cocoadocs.org/docsets/FireMock)
[![Build Status](https://travis-ci.org/Magiic/FireMock.svg?branch=master)](https://travis-ci.org/Magiic/FireMock)
[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Getting Started

To mock your requests you need to add files contains your structure response data (Json, XML, etc.) and install FireMock via Cocoapods.

### Installing

#### CocoaPods

To integrate FireMock into your Xcode project using CocoaPods, specify it in your Podfile:

```swift
pod 'FireMock'
```

## Usage

### Import FireMock

```swift
@import FireMock
```

### Swift4 Only

For swift4, you need to add initialization on your AppDelegate.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {

    override init() {
        super.init()
        URLSessionConfiguration.classInit
    }

    //...
}
```

### Enable FireMock

Add this code in your application to enable FireMock.

```swift
FireMock.enabled(true)
```

### Implement FireMockProtocol

For each request you can associate a mock that will be used to return the desired response. Creating a mock is very simple. Implement the FireMockProtocol protocol and define its characteristics. All are optional except the mockFile function that expects the file to be used when the request is started.

For example if you have a service to fetch news with multiple possible responses :

```swift
enum NewsMock: FireMockProtocol {
    case success
    case successEmpty
    case failedParameters

    public var bundle: Bundle { return Bundle.main }

    public var afterTime: TimeInterval { return 0.0 }

    public var parameters: [String]? { return nil }

    public var headers: [String : String]? { return nil }

    public var statusCode: Int { return 200 }

    public var httpVersion: String? { return "1.1" }

    public var name: String? { return "Fetch News" }

    public func mockFile() -> String {
        switch self {
        case .success:
            return "success.json"
        case .successEmpty:
            return "successEmpty.json"
        case .failedParameters:
            return "failedParameters.json"
        }
    }
}
```
See FireMockProtocol for more information about properties.

### Register

Last step, register one or more mocks for specific request. Specify for which url it is associated and if it is enabled.
You can disable during compilation and enable it on runtime. You can also change the mock during runtime. This is described below.

```swift
FireMock.register(mock: NewsMock.success, NewsMock.successEmpty, httpMethod: .get, forURL: url, enabled: true)
```

If you want to be more flexible with url, you can register with a Regular Expression. It useful when you don't know exactly the url.

```swift
let regex = "https?://foo.com(/\\S*)?"
FireMock.register(mock: NewsMock.success, NewsMock.successEmpty, NewsMock.failedParameters, regex: regex, httpMethod: .get, enabled: true)
```

### Host Condition

You can use your mock files with specific hosts only. If empty, mock works for all hosts.

```swift
FireMock.onlyHosts = ["foo.com"]
```

You can exclude hosts.

```swift
FireMock.excludeHosts = ["foo.com"]
```

### Debug

Debug information about requests intercepted and enable or disable mocks. You can set 2 different levels information.

```swift
FireMock.debug(enabled: true)
```

### Enable and Change Mock on runtime

All mocks can be enable or not on runtime. FireMock provide a ViewController that list all mocks registers by you. So it becomes easy to switch from one state to another without having to change code. You can also change the mock during runtime if you have registers 2 or more.

```swift
FireMock.presentMockRegisters(from: self, backTapped: nil)
```

## Integrate with 3rd Party

FireMock handle automatically integration with 3rd Party network when it used URLSession API. FireMock uses Swizzling method to add FireURLProtocol in protocolClasses array from session configuration.

## License

This project is licensed under the MIT License.
