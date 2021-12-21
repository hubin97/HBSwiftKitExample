//
//  Extension+Array.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/12/21.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation

// MARK: - global var and methods
fileprivate typealias Extension_Array = Array

// MARK: - private mothods
extension Extension_Array {

    public func toData() -> Data? {
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("is not a valid json object")
            return nil
        }
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }

    public func toJSONString() -> String? {
        guard let data = self.toData() else { return nil }
        return String(data:data, encoding: String.Encoding.utf8)
    }
}

// MARK: - call backs
extension Extension_Array { 
}

// MARK: - delegate or data source
extension Extension_Array { 
}

// MARK: - other classes
