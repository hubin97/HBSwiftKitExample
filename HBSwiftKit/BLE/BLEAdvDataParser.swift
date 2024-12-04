//
//  BLEAdvDataParser.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/11/26.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

// MARK: - global var and methods
public protocol BLEAdvDataParser {
    associatedtype ParsedData
    func parse(advertisementData: [String: Any]) -> ParsedData?
}

// MARK: - 以下为示例
// 外设名称解析器
public struct PeripheralNameParser: BLEAdvDataParser {
    public typealias ParsedData = String
    public func parse(advertisementData: [String: Any]) -> String? {
        return advertisementData["kCBAdvDataLocalName"] as? String
    }
    
    public init() {}
}

// 制造商数据解析器
public struct ManufacturerDataParser: BLEAdvDataParser {
    public typealias ParsedData = [UInt8]
    public func parse(advertisementData: [String: Any]) -> [UInt8]? {
        guard let data = advertisementData["kCBAdvDataManufacturerData"] as? Data else { return nil }
        return [UInt8](data)
    }
    
    public init() {}
}

// MAC; 
//!!!: 一般根据具体业务和设备开发协议来解析
public struct MACParser: BLEAdvDataParser {
    public typealias ParsedData = String
    public func parse(advertisementData: [String: Any]) -> String? {
        guard let bytes = advertisementData["kCBAdvDataManufacturerData"] as? Data, bytes.count >= 8 else { return nil }
        let macData = bytes[3...8]
        let mac = [UInt8](macData).reversed().compactMap {String(format: "%02x", $0).uppercased()}.joined(separator: ":")
        return mac
    }
    
    public init() {}
}
