# HBSwiftKit

[![Version](https://img.shields.io/cocoapods/v/HBSwiftKit.svg?style=flat)](https://cocoapods.org/pods/HBSwiftKit)
[![License](https://img.shields.io/cocoapods/l/HBSwiftKit.svg?style=flat)](https://cocoapods.org/pods/HBSwiftKit)
[![Platform](https://img.shields.io/cocoapods/p/HBSwiftKit.svg?style=flat)](https://cocoapods.org/pods/HBSwiftKit)

⚠️ **注意**  
本项目已不再维护或可能已经过期。请使用新的 [`AppStart`](https://github.com/hubin97/AppStart) 库以获得最新功能和支持。

## 示例

要运行示例项目，请先克隆 repo，然后从示例目录运行“pod install”。

## 要求

iOS 13.0+

## 功能

1. HBSwiftKit 是一组实用的 Swift 扩展和工具的集合。
2. `Base模块`提供了一组用于 UI 开发的工具，包括基础组件和扩展, 例如 ViewController、NavigationController; UIColor、UIFont、UIView、UIImage 等。
3. `Base模块`还提供了 国际化工具 `LocalizedUtils`, 路由协议Navigator以及MVVM结构协议(参考Swifthub)
4. `HTTP模块`提供 基于 `Moya + PromiseKit + ObjectMapper + ProgressHUD` 的封装搭建, 更加简洁且面向业务. 详细参考 [HTTP_README](./HBSwiftKit/HTTP/Core/HTTP_README.md)
5. `BLE模块`提供了链式配置和链式回调, 以及rx订阅. 简易全局业务监听.详细参考 [BLE_README](./HBSwiftKit/BLE/BLE_README.md)
6. 分支`shortcuts`, 提供Siri及Shortcuts的快捷指令示例.
7. 分支`wechat_qrcode`, 提供微信扫码以及华为扫码的集成示例.

## 安装

HBSwiftKit 可通过 [CocoaPods](https://cocoapods.org) 获取。要安装它，只需将以下行添加到您的 Podfile 中：

```ruby
pod 'HBSwiftKit'

# 模块安装
pod 'HBSwiftKit/Base'
pod 'HBSwiftKit/HTTP'
pod 'HBSwiftKit/BLE'
```

## 作者

970216474@qq.com

## 许可证

HBSwiftKit 在 MIT 许可证下可用。有关更多信息，请参阅 LICENSE 文件。
