# FireMock
FireMock help to build mock. If you are looking for an easy way to test your request or work with your server which is not ready so you are in a good place. Test your apps with fake response data and files with a short effort.

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

### Enable FireMock

Add this code in your application to enable FireMock.

```swift
FireMock.enabled(true)
```

### Implement FireMockProtocol

For example if you have a service to fetch news with multiple possible responses :

```swift
enum NewsMock: FireMockProtocol {
    case success
    case failedParameters

    public var bundle: Bundle { return Bundle.main }

    public var afterTime: TimeInterval { return 0.0 }

    public var parameters: [String]? { return nil }

    public var headers: [String : String]? { return nil }

    public var statusCode: Int { return 200 }

    public var httpVersion: String? { return "1.1" }

    public func mockFile() -> String {
        switch self {
        case .success:
            return "success.json"
        case .failedParameters:
            return "failedParameters.json"
        }
    }
}
```
See FireMockProtocol to more information.

### Register

```swift
let mock = NewsMock.success
FireMock.register(mock: mock, httpMethod: .get, forURL: url, enabled: true)
```

### Host Condition

You can use your mock files with specific hosts only. If empty, mock works for all hosts.

```swift
FireMock.onlyHosts = ["xxx.com"]
```

You can exclude hosts.

```swift
FireMock.excludeHosts = ["xxx.com"]
```

## Integrate with Alamofire

If you use Alamofire 3rd Party, you need create a new URLSessionConfiguration and add FireURLProtocol.

```swift
let configuration = URLSessionConfiguration.default
if FireMock.isEnabled {
  configuration.protocolClasses?.insert(FireURLProtocol.self as AnyClass, at: 0)
}
let manager = SessionManager(configuration: configuration)
```

## License

This project is licensed under the MIT License
