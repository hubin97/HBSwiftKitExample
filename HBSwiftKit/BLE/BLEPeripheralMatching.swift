//
//  BLEPeripheralMatching.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/11/26.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import CoreBluetooth

// MARK: - Matching Protocol
public protocol BLEPeripheralMatching {
    /// 判断可以连接到指定外设 (追加匹配规则)
    func shouldConnect(to peripheral: CBPeripheral, advertisementData: [String: Any]) -> Bool
}

// MARK: - private mothods
extension BLEPeripheralMatching {
    /// 默认规则：UUID 和广播包键值匹配
    func shouldConnect(to peripheral: CBPeripheral, advertisementData: [String: Any]) -> Bool {
        // 默认行为实现（例如：检查 UUID 或者广播包内容）
        return true
    }
}

// MARK: - Strategy
/// 默认策略：允许所有设备
public struct DefaultMatchingStrategy: BLEPeripheralMatching {
    public func shouldConnect(to peripheral: CBPeripheral, advertisementData: [String: Any]) -> Bool {
        return true
    }
}

// MARK: - 以下为示例
/// 字节匹配策略
public struct StartsByteMatchingStrategy: BLEPeripheralMatching {
    let targetBytes: [UInt8]
    public func shouldConnect(to peripheral: CBPeripheral, advertisementData: [String: Any]) -> Bool {
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            return matchesByteArray(manufacturerData, byteArray: targetBytes)
        }
        return false
    }

    private func matchesByteArray(_ data: Data, byteArray: [UInt8]) -> Bool {
        guard byteArray.count <= data.count else { return false }
        return data.starts(with: byteArray)
    }
}

/// 正则表达式匹配策略
public struct RegexMatchingStrategy: BLEPeripheralMatching {
    public enum MatchingMode {
        /// 基于外设名称前缀匹配
        case namePrefix(String)
        /// 基于广播包中的字节匹配
        case advertisementData([UInt8])
    }
    
    private var mode: MatchingMode
    
    // 初始化时选择匹配模式
    public init(mode: MatchingMode) {
        self.mode = mode
    }

    public func shouldConnect(to peripheral: CBPeripheral, advertisementData: [String: Any]) -> Bool {
        switch mode {
        case .namePrefix(let prefix):
            return matchesNamePrefix(peripheral.name ?? "", prefix: prefix)
        case .advertisementData(let bytes):
            return matchesAdvertisementData(advertisementData, targetBytes: bytes)
        }
    }

    // 根据前缀匹配外设名称
    private func matchesNamePrefix(_ name: String, prefix: String) -> Bool {
        return name.hasPrefix(prefix)
    }

    // 根据字节匹配广播包中的数据
    private func matchesAdvertisementData(_ advertisementData: [String: Any], targetBytes: [UInt8]) -> Bool {
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            return matchesByteArray(manufacturerData, byteArray: targetBytes)
        }
        return false
    }

    // 判断广播包中的字节是否匹配目标字节
    private func matchesByteArray(_ data: Data, byteArray: [UInt8]) -> Bool {
        guard byteArray.count <= data.count else { return false }
        return data.starts(with: byteArray)
    }
}
