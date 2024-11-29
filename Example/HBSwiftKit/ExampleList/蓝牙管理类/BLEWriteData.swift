//
//  BLEWriteData.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/11/29.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import CoreBluetooth

// 封装每次写入请求的数据包
struct BLEWriteData: Comparable {
    
    static func < (lhs: BLEWriteData, rhs: BLEWriteData) -> Bool {
        return lhs.priority < rhs.priority
    }

    /// 外设
    let peripheral: CBPeripheral
    /// 写入特征
    let writeChar: CBCharacteristic
    /// 外设UUID
    let uuid: String

    let data: Data
    let timeout: TimeInterval
//    var timer: Timer?

    let requestId: UUID
    /// 优先级
    var priority: Int
    
    // 初始化时为每个写入请求生成唯一的UUID
    init(peripheral: CBPeripheral, writeChar: CBCharacteristic, data: Data, timeout: TimeInterval = 3.0, priority: Int = 0) {
        self.requestId = UUID()
        self.peripheral = peripheral
        self.writeChar = writeChar
        self.uuid = peripheral.identifier.uuidString
        
        self.data = data
        self.timeout = timeout
        self.priority = priority
    }
}
