//
//  Extension+Dictionary.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/4/21.
//  Copyright © 2020 Wingto. All rights reserved.

//单元测试 ✅
import Foundation

//MARK: - global var and methods
fileprivate typealias Extension_Dictionary = Dictionary

//MARK: - main class

//MARK: - private mothods
extension Extension_Dictionary {
    
    public mutating func setValue(_ value: Dictionary.Value, forKey key: Dictionary.Key) {
        self[key] = value
    }

    public func value(forKey key: Dictionary.Key) -> Any? {
        if self.keys.contains(key) {
            return self[key]
        }
        return nil
    }
    
    public func toData() -> Data? {
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("is not a valid json object")
            return nil
        }
        /**
         //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式带"\n"
         <<<<<<<<<
         Optional(43 bytes)
         Optional("{\"bbb\":\"444\",\"ccc\":[555,666,777],\"aaa\":123}")
         >>>>>>>>>
         Optional(77 bytes)
         Optional("{\n  \"ccc\" : [\n    555,\n    666,\n    777\n  ],\n  \"bbb\" : \"444\",\n  \"aaa\" : 123\n}")
         */
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
    
    public func toJSONString() -> String? {
        guard let data = self.toData() else { return nil }
        return String(data:data, encoding: String.Encoding.utf8)
    }
}

//MARK: - call backs
extension Extension_Dictionary {
    
}

//MARK: - delegate or data source
extension Extension_Dictionary {
    
}

//MARK: - other classes
