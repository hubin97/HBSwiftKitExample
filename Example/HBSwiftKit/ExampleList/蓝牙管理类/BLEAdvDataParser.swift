//
//  BLEAdvDataParser.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/11/26.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

// MARK: - global var and methods
protocol BLEAdvDataParser {
    associatedtype ParsedData
    func parse(advertisementData: [String: Any]) -> ParsedData?
}

// MARK: - 以下为示例
// 外设名称解析器
struct PeripheralNameParser: BLEAdvDataParser {
    typealias ParsedData = String
    func parse(advertisementData: [String: Any]) -> String? {
        return advertisementData["kCBAdvDataLocalName"] as? String
    }
}

// 制造商数据解析器
struct ManufacturerDataParser: BLEAdvDataParser {
    typealias ParsedData = [UInt8]
    func parse(advertisementData: [String: Any]) -> [UInt8]? {
        guard let data = advertisementData["kCBAdvDataManufacturerData"] as? Data else { return nil }
        return [UInt8](data)
    }
}

// MAC; 
//!!!: 一般根据具体业务和设备开发协议来解析
struct MACParser: BLEAdvDataParser {
    typealias ParsedData = String
    func parse(advertisementData: [String: Any]) -> String? {
        guard let bytes = advertisementData["kCBAdvDataManufacturerData"] as? Data, bytes.count >= 8 else { return nil }
        let macData = bytes[3...8]
        let mac = [UInt8](macData).reversed().compactMap {String(format: "%02x", $0).uppercased()}.joined(separator: ":")
        return mac
    }
}
