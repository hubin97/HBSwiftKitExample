# HBSwiftKit

[![Version](https://img.shields.io/cocoapods/v/HBSwiftKit.svg?style=flat)](https://cocoapods.org/pods/HBSwiftKit)
[![License](https://img.shields.io/cocoapods/l/HBSwiftKit.svg?style=flat)](https://cocoapods.org/pods/HBSwiftKit)
[![Platform](https://img.shields.io/cocoapods/p/HBSwiftKit.svg?style=flat)](https://cocoapods.org/pods/HBSwiftKit)

中文文档: [README_CN.md](./README_CN.md)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 13.0+

## Features

1. HBSwiftKit is a collection of practical Swift extensions and tools.
2. The Base module provides a set of tools for UI development, including basic components and extensions, such as ViewController, NavigationController; UIColor, UIFont, UIView, UIImage, etc.
3. The Base module also provides internationalization tools LocalizedUtils, routing protocol Navigator and MVVM structure protocol (refer to Swifthub)
4. The HTTP module provides encapsulation based on Moya + PromiseKit + ObjectMapper + ProgressHUD, which is more concise and business-oriented. For details, refer to [HTTP_README](./HBSwiftKit/HTTP/Core/HTTP_README.md)
5. The BLE module provides chain configuration and chain callback, as well as rx subscription. Simple global business monitoring. For details, refer to [BLE_README](./HBSwiftKit/BLE/BLE_README.md)
6. Branch shortcuts, provides shortcut examples for Siri and Shortcuts.
7. Branch wechat_qrcode, provides integration examples for WeChat QR code scanning and Huawei QR code scanning.

## Installation

HBSwiftKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HBSwiftKit'

# Module installation
pod 'HBSwiftKit/Base'
pod 'HBSwiftKit/HTTP'
pod 'HBSwiftKit/BLE'
```

## Author

970216474@qq.com

## License

HBSwiftKit is available under the MIT license. See the LICENSE file for more info.
