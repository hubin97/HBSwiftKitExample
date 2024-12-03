//
//  Extension+Dictionary.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/4/21.
//  Copyright © 2020 Wingto. All rights reserved.

//单元测试 ✅
import Foundation
import UIKit

//MARK: - global var and methods
fileprivate typealias Extension_Dictionary = Dictionary

//MARK: - main class

//MARK: - private mothods
extension Extension_Dictionary {

    /// 也可以选用系统方法替代 public mutating func updateValue(_ value: Value, forKey key: Key) -> Value?
    public mutating func setValue(_ value: Dictionary.Value, forKey key: Dictionary.Key) {
        self[key] = value
    }

    public func value(forKey key: Dictionary.Key) -> Any? {
        if self.keys.contains(key) {
            return self[key]
        }
        return nil
    }
}

//MARK: - call backs
/**
 //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式带"\n"
 <<<<<<<<<
 Optional(43 bytes)
 Optional("{\"bbb\":\"444\",\"ccc\":[555,666,777],\"aaa\":123}")
 >>>>>>>>>
 Optional(77 bytes)
 Optional("{\n  \"ccc\" : [\n    555,\n    666,\n    777\n  ],\n  \"bbb\" : \"444\",\n  \"aaa\" : 123\n}")
 */
extension Extension_Dictionary {

    /// dict转data
    public var data: Data? {
        if (JSONSerialization.isValidJSONObject(self)) {
            return try? JSONSerialization.data(withJSONObject: self, options: [])
        }
        return nil
    }

    /// dict转string
    public var string: String? {
        if let data = self.data {
            return String(data: data, encoding: String.Encoding.utf8)
        }
        return nil
    }
}

//MARK: - delegate or data source
extension Extension_Dictionary {
    
}
