//
//  Extension+Data.swift
//  test
//
//  Created by hubin.h@wingto.cn on 2020/8/11.
//  Copyright © 2020 WingTo. All rights reserved.

import Foundation

public typealias Extension_Data = Data

extension Extension_Data {
    
    /// Data To Dictionary
    /// - Returns: Dictionary?
    public func toDict() -> Dictionary<String, Any>? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            let dic = json as! Dictionary<String, Any>
            return dic
        } catch _ {
            return nil
        }
    }
    
    /// Data To Array
    /// - Returns: Array?
    public func toArray() -> [Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            let array = json as! [Any]
            return array
        } catch _ {
            return nil
        }
    }
    
    /// Data To String
    /// - Returns: String?
    public func toString() -> String? {
        return String(data: self, encoding: String.Encoding.utf8)
    }
    
    /// Data To jsonObject
    /// - Returns: AnyObject?
    public func toJson() -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: self , options: .allowFragments) as AnyObject
        } catch {
            print("tojsonErro: \(error)")
        }
        return nil
    }
    
    func toDataString() -> String? {
         return String(format: "%@", self as CVarArg)
    }
}