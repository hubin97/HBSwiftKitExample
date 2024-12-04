//
//  BLEWriteData.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/11/29.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import CoreBluetooth

// 封装每次写入请求的数据包
public struct BLEWriteData: Comparable {
    
    public static func < (lhs: BLEWriteData, rhs: BLEWriteData) -> Bool {
        return lhs.priority < rhs.priority
    }

    /// 外设
    public let peripheral: CBPeripheral
    /// 写入特征
    public let writeChar: CBCharacteristic
    /// 外设UUID
    public let uuid: String

    /// 写入数据
    public let data: Data
    /// 写入超时时间
    public let timeout: TimeInterval
    /// 优先级
    public var priority: Int
    /// 请求ID
    public let requestId: UUID

    // 初始化时为每个写入请求生成唯一的UUID
    public init(peripheral: CBPeripheral, writeChar: CBCharacteristic, data: Data, timeout: TimeInterval = 3.0, priority: Int = 0) {
        self.requestId = UUID()
        self.peripheral = peripheral
        self.writeChar = writeChar
        self.uuid = peripheral.identifier.uuidString
        
        self.data = data
        self.timeout = timeout
        self.priority = priority
    }
}

extension BLEWriteData {
    
    public var description: String {
        return "BLEWriteData: \(requestId), \(uuid), \(peripheral), \(writeChar), \(data.map { String(format: "%02hhx", $0) })"
    }
}
