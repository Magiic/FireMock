# FireMock
FireMock help to build mock. If you are looking for an easy way to test your request or work with your server which is not ready so you are in a good place. Test your apps with fake response data and files with a short effort.

## Getting Started

To mock your requests you need to add files contains your structure response data (Json, XML, etc.) and install FireMock via Cocoapods.

### Installing

#### CocoaPods

To integrate FireMock into your Xcode project using CocoaPods, specify it in your Podfile:

```
pod 'FireMock'
```

## Usage

### Import FireMock

```
@import FireMock
```

### Enable FireMock

Add this code in your application to enable FireMock.

```
FireMock.enabled(true)
```

### Implement FireMockProtocol

For example if you have a service to fetch news with multiple possible responses :

```
enum NewsMock: FireMockProtocol {
    case success
    case failedParameters

    public var bundle: Bundle { return Bundle.main }
    
    public static var defaultMock: FireMockProtocol =  NewsMock.success
    
    public var afterTime: TimeInterval { return 0.0 }
    
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

### Register

```
let mock = NewsMock.success
FireMock.registerMock(mock: mock, forURL: url, enabled: true, httpResponse: nil)
```

## Integrate with Alamofire

If you use Alamofire 3rd Party, you need create a new URLSessionConfiguration and add FireURLProtocol. 

## License

This project is licensed under the MIT License

