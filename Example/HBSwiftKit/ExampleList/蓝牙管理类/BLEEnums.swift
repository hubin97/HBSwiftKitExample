//
//  BLEEnums.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/11/27.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import CoreBluetooth

/// 扫描状态
enum BLEScanState {
    case started
    case stopped
}

/// 断开连接原因
enum DisconnectReason {
    /// 用户主动断开
    case userInitiated
    /// 系统异常断开
    case unexpected(Error)
}

/// 连接状态
enum BLEConnectionState {
    /// 正在连接
    case connecting(CBPeripheral)
    /// 连接成功
    case connected(CBPeripheral)
    /// 连接失败 (系统上报错误的)
    case failed(CBPeripheral, Error?)
    /// 自定义连接超时
    case timedOut(CBPeripheral)
    /// 断开连接 (包含断开原因; 用户主动断开或系统异常断开等)
    case disconnected(CBPeripheral, reason: DisconnectReason)
    /// 通道就绪
    case onReady(BLEChannalReadyResult)
}

/// 连接通道建立结果
enum BLEChannalReadyResult {
    case success(CBPeripheral, CBService)
    case failure(CBPeripheral, Error)
}

/// 特征值更新结果
enum BLECharValueUpdateResult {
    case success(CBPeripheral, CBCharacteristic, Data)
    case failure(CBPeripheral, CBCharacteristic, Error)
}

/// 写入结果
enum BLECharWriteResult {
    case success(CBPeripheral, CBCharacteristic)
    case failure(CBPeripheral, CBCharacteristic, Error)
}
