//
//  BLEReconnectable.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/11/26.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import CoreBluetooth

// MARK: - main class
protocol BLEReconnectable where Self: BLEManager {
    
    /// 是否自动重连
    var autoReconnect: Bool { get set }
    /// 最大重连次数
    var maxReconnectAttempts: Int { get set }
    /// 重连超时时间
    var reconnectTimeout: TimeInterval { get set }
    /// 重连阶段及结果回调 (成功或失败, 达到最大重连次数)
    var reconnectPhase: ((CBPeripheral, BLEReconnectState) -> Void)? { get set }
    /// 当前重连尝试次数
    var currentReconnectAttempts: [CBPeripheral: Int] { get set }

    // 是否已经连接到指定外设
    func isConnected(to peripheral: CBPeripheral) -> Bool

    // 启动重连
    func startReconnect(for peripheral: CBPeripheral)

    // 执行重连尝试
    func attemptReconnect(for peripheral: CBPeripheral)
}

extension BLEReconnectable {
    
    // 默认的重连实现
    func startReconnect(for peripheral: CBPeripheral) {
        guard autoReconnect else { return }  // 如果没有启用自动重连，则直接返回
        reconnectPhase?(peripheral, .started)
        currentReconnectAttempts[peripheral] = 0
        attemptReconnect(for: peripheral)
    }
    
    // 执行重连尝试
    func attemptReconnect(for peripheral: CBPeripheral) {
        
        // 如果外设已经连接，停止重连
        if isConnected(to: peripheral) {
            printLog("外设已连接，无需进一步重连: \(peripheral.name ?? "未知")")
            reconnectPhase?(peripheral, .stopped(.success))
            onConnectionStateChange?(.connected(peripheral), peripheral)
            return
        }
        
        guard let currentAttempts = self.currentReconnectAttempts[peripheral], currentAttempts < maxReconnectAttempts else {
            printLog("达到最大重连次数，停止重连")
            reconnectPhase?(peripheral, .stopped(.timeout))

            // 超过最大重连次数，触发超时回调
            onConnectionStateChange?(.timedOut(peripheral), peripheral)
            disconnect(peripheral)
            return
        }
        
        // 增加重连次数
        self.currentReconnectAttempts[peripheral] = currentAttempts + 1
        self.printLog("尝试重新连接: \(peripheral.name ?? "未知")，第 \(currentAttempts + 1) 次重连")

        DispatchQueue.main.asyncAfter(deadline: .now() + reconnectTimeout) { [weak self] in
            self?.connect(to: peripheral)
            
            // 如果连接失败，继续重连
            self?.attemptReconnect(for: peripheral)
        }
    }
}
