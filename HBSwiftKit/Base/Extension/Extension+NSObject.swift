//
//  Extension+NSObject.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/12/20.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation

// MARK: - global var and methods
fileprivate typealias Extension_NSObject = NSObject

// MARK: - main class
// MARK: - private mothods
extension Extension_NSObject {

    /// 获取类的属性列表
    /// - Returns: 属性名列表
    public func get_class_copyPropertyList() -> [String] {
        var outCount: UInt32 = 0
        let propers: UnsafeMutablePointer<objc_property_t>! = class_copyPropertyList(self.classForCoder, &outCount)
        let count: Int = Int(outCount)
        var names: [String] = [String]()
        for i in 0...(count-1) {
            let aPro: objc_property_t = propers[i]
            if let proName:String = String(utf8String: property_getName(aPro)){
                names.append(proName)
            }
        }
        return names
    }

    /// 获取类的方法列表
    /// - Returns: 方法名列表
    public func get_class_copyMethodList() -> [String] {
        var outCount: UInt32 = 0
        let methods: UnsafeMutablePointer<objc_property_t>! = class_copyMethodList(self.classForCoder, &outCount)
        let count: Int = Int(outCount)
        var names: [String] = [String]()
        for i in 0...(count-1) {
            let aMet: objc_property_t = methods[i]
            if let methodName:String = String(utf8String: property_getName(aMet)){
                names.append(methodName)
            }
        }
        return names
    }

//    可以使用 reflect() 来遍历一个实例里面所有的属性，除了 computed property 以外的所有属性都可遍历。没找到方法直接对 class 进行遍历，所以必须至少创建一个实例才能工作
    public func getAllPropertyList() -> [(String, Any?)] {
        var tempa = [(String, Any?)]()
        let mirror =  Mirror.init(reflecting: self)
        for item in mirror.children {
            tempa.append((String(item.label ?? ""), item.value))
        }
        return tempa
    }
    
}

// MARK: - call backs
extension Extension_NSObject { 
}

// MARK: - delegate or data source
extension Extension_NSObject { 
}

// MARK: - other classes
