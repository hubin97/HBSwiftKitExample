//
//  BLEManager.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/11/26.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import CoreBluetooth

// MARK: - global var and methods
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
    case connecting(CBPeripheral)
    case connected(CBPeripheral)
    // 系统报告的连接失败
    case failed(CBPeripheral, Error?)
    // 自定义连接超时
    case timedOut(CBPeripheral)
    case disconnected(CBPeripheral, reason: DisconnectReason)
}

// MARK: - main class
class BLEManager: NSObject, BLEReconnectable {

    static let shared = BLEManager()

    // 开启debug模式
    private var debugMode = false
    // 插入日志标记
    private var logTag = "\(Date()) [BLEManager]: "
    
    // MARK: BLEReconnectable 协议属性
    var autoReconnect = false
    var maxReconnectAttempts = 3  // 最大重连次数
    var reconnectTimeout: TimeInterval = 10  // 重连超时
    var onMaxReconnectAttemptsReached: ((CBPeripheral) -> Void)?
    var onReconnectStarted: ((CBPeripheral) -> Void)?
    var onReconnectFinished: ((CBPeripheral) -> Void)?
    var currentReconnectAttempts: [CBPeripheral: Int] = [:]
    
    // MARK: Central Manager Delegate
    private var centralManager: CBCentralManager!
    private var onStateChanged: ((CBManagerState) -> Void)?
    private var onDataReceived: ((CBPeripheral, Data) -> Void)?
    
    private var onConnected: ((CBPeripheral) -> Void)?
    private var onConnectedPeripherals: (([CBPeripheral]) -> Void)?
    private var onDisconnected: ((CBPeripheral, Error?) -> Void)?
    private var onPeripheralDiscovered: ((CBPeripheral) -> Void)?
    private var onScanCompleted: (([CBPeripheral]) -> Void)?
    private var onConnectionTimeout: ((CBPeripheral) -> Void)?
    
    private var scanTimeoutWorkItem: DispatchWorkItem?
    private var connectionTimeoutTasks: [CBPeripheral: DispatchWorkItem] = [:]
    
    // 回调扫描状态
    var onScanStateChange: ((BLEScanState) -> Void)?
    // 回调连接状态
    var onConnectionStateChange: ((BLEConnectionState, CBPeripheral) -> Void)?
      
    // 过滤条件
    // 用于设备匹配的策略，默认实现匹配所有设备
    private var matchingStrategy: BLEPeripheralMatching = DefaultMatchingStrategy()
    private var targetServices: [CBUUID] = []
    
    // 已发现的外设数组
    private var _discoveredPeripherals: [CBPeripheral] = []
    var discoveredPeripherals: [CBPeripheral] {
        return _discoveredPeripherals
    }
    
    // 已连接的所有外设
    private var connectedPeripherals: [CBPeripheral] = []

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // debug log
    func printLog(_ message: String) {
        if debugMode {
            print(logTag + message)
        }
    }
}

// MARK: - Reconnectable 协议方法
extension BLEManager {
    
    // 判断是否已连接到指定外设
    func isConnected(to peripheral: CBPeripheral) -> Bool {
        return connectedPeripherals.contains(peripheral)
    }
}

// MARK: - Central Manager Delegate
extension BLEManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        printLog("蓝牙状态更新: \(central.state.rawValue)")
        onStateChanged?(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if matchingStrategy.shouldConnect(to: peripheral, advertisementData: advertisementData) {
            if !_discoveredPeripherals.contains(peripheral) {
                _discoveredPeripherals.append(peripheral)
                
                printLog("发现符合规则的外设: \(peripheral.name ?? "未知")")
                if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
                    printLog("广播包数据: \(manufacturerData.map({ String(format: "%02x", $0) }).joined(separator: " "))")
                }
                
                onPeripheralDiscovered?(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 清除该外设的超时任务
        connectionTimeoutTasks[peripheral]?.cancel()
        connectionTimeoutTasks.removeValue(forKey: peripheral)
        
        // 更新连接外设数组
        connectedPeripherals.append(peripheral)
        
        printLog("已连接到: \(peripheral.name ?? "未知")")
        
        onConnected?(peripheral)
        onConnectedPeripherals?(connectedPeripherals)
        onConnectionStateChange?(.connected(peripheral), peripheral)
        //onReconnectFinished?(peripheral)

        peripheral.delegate = self
        peripheral.discoverServices(targetServices.isEmpty ? nil : targetServices)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let peripheralName = peripheral.name ?? "未知"
        let errorDescription = error?.localizedDescription ?? "无"
        let disconnectReason = error == nil ? "用户主动断开" : "外设断开连接"
        printLog("\(disconnectReason): \(peripheralName), Error: \(errorDescription)")
        
        // 移除已连接状态
        connectedPeripherals.removeAll { $0 == peripheral }
        
        onDisconnected?(peripheral, error)
        
        // 如果 error 为 nil，说明是用户主动断开连接，不需要重连
        if let error = error {
            printLog("是否开启自动重连: \(autoReconnect)")
            onConnectionStateChange?(.disconnected(peripheral, reason: .unexpected(error)), peripheral)
            startReconnect(for: peripheral)
        } else {
            onConnectionStateChange?(.disconnected(peripheral, reason: .userInitiated), peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        printLog("连接失败: \(peripheral.name ?? "未知")，错误: \(error?.localizedDescription ?? "无")")
        onConnectionStateChange?(.failed(peripheral, error), peripheral)
        currentReconnectAttempts[peripheral] = (currentReconnectAttempts[peripheral] ?? 0) + 1
        // 尝试重连
        startReconnect(for: peripheral)
    }
    
    // MARK: Data Handling
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            printLog("更新特征值失败: \(error.localizedDescription)")
            return
        }
        if let data = characteristic.value {
            onDataReceived?(peripheral, data)
        }
    }
}

// MARK: - Scanning / Connecting
extension BLEManager {
    
    // MARK: Scanning
    @discardableResult
    func startScanning(timeout: TimeInterval? = nil) -> Self {
        onScanStateChange?(.started)
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        printLog("开始扫描...")

        // 如果设置了超时
        if let timeout = timeout {
            scanTimeoutWorkItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.stopScanning()
                self.onScanCompleted?(self.discoveredPeripherals)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: scanTimeoutWorkItem!)
        }
        
        return self
    }
    
    func stopScanning() {
        onScanStateChange?(.stopped)
        centralManager.stopScan()
        scanTimeoutWorkItem?.cancel()
        scanTimeoutWorkItem = nil
        printLog("扫描停止。")
    }
    
    // MARK: Connecting
    @discardableResult
    func connect(to peripheral: CBPeripheral, options: [String: Any]? = nil, timeout: TimeInterval? = nil) -> Self {
        printLog("开始连接: \(peripheral.name ?? "未知")")
        onConnectionStateChange?(.connecting(peripheral), peripheral)

        centralManager.connect(peripheral, options: options)

        // 为该外设设置连接超时任务
        if let timeout = timeout {
            let timeoutTask = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                printLog("连接超时: \(peripheral.name ?? "未知")")
                
                self.onConnectionStateChange?(.timedOut(peripheral), peripheral)
                self.centralManager.cancelPeripheralConnection(peripheral)
                self.onConnectionTimeout?(peripheral)
            }
            connectionTimeoutTasks[peripheral] = timeoutTask
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: timeoutTask)
        }
        
        return self
    }
    
    @discardableResult
    func connect(to peripherals: [CBPeripheral], options: [String: Any]? = nil, timeout: TimeInterval? = nil) -> Self {
        peripherals.forEach { connect(to: $0, options: options, timeout: timeout) }
        return self
    }
    
    @discardableResult
    func disconnect(_ peripheral: CBPeripheral) -> Self {
        centralManager.cancelPeripheralConnection(peripheral)
        return self
    }
}

// MARK: - Chainable Methods
extension BLEManager {
    
    @discardableResult
    func setDebugMode(_ isDebug: Bool) -> Self {
        self.debugMode = isDebug
        return self
    }
    
    @discardableResult
    func setLogTag(_ tag: String) -> Self {
        self.logTag = tag
        return self
    }
    
    @discardableResult
    func setMatchingStrategy(_ strategy: BLEPeripheralMatching) -> Self {
        self.matchingStrategy = strategy
        return self
    }
    
    @discardableResult
    func setTargetServices(_ services: [CBUUID]) -> Self {
        self.targetServices = services
        return self
    }
    
    @discardableResult
    func setOnStateChanged(_ handler: @escaping (CBManagerState) -> Void) -> Self {
        self.onStateChanged = handler
        return self
    }

    @discardableResult
    func setOnScanStateChange(_ handler: @escaping (BLEScanState) -> Void) -> Self {
        self.onScanStateChange = handler
        return self
    }
    
    @discardableResult
    func setOnConnectionStateChange(_ handler: @escaping (BLEConnectionState, CBPeripheral) -> Void) -> Self {
        self.onConnectionStateChange = handler
        return self
    }
    
    @discardableResult
    func setOnDataReceived(_ handler: @escaping (CBPeripheral, Data) -> Void) -> Self {
        self.onDataReceived = handler
        return self
    }
    
    @discardableResult
    func setOnConnected(_ handler: @escaping (CBPeripheral) -> Void) -> Self {
        self.onConnected = handler
        return self
    }
    
    @discardableResult
    func setOnConnectedPeripherals(_ handler: @escaping ([CBPeripheral]) -> Void) -> Self {
        self.onConnectedPeripherals = handler
        return self
    }
    
    @discardableResult
    func setOnDisconnected(_ handler: @escaping (CBPeripheral, Error?) -> Void) -> Self {
        self.onDisconnected = handler
        return self
    }
    
    @discardableResult
    func setOnPeripheralDiscovered(_ handler: @escaping (CBPeripheral) -> Void) -> Self {
        self.onPeripheralDiscovered = handler
        return self
    }
    
    @discardableResult
    func setOnScanCompleted(_ handler: @escaping ([CBPeripheral]) -> Void) -> Self {
        self.onScanCompleted = handler
        return self
    }
    
    @discardableResult
    func setOnConnectionTimeout(_ handler: @escaping (CBPeripheral) -> Void) -> Self {
        self.onConnectionTimeout = handler
        return self
    }
    
    // MARK: - Reconnectable 协议方法
    @discardableResult
    func onReconnectStarted(_ handler: @escaping (CBPeripheral) -> Void) -> Self {
        self.onReconnectStarted = handler
        return self
    }
    
    @discardableResult
    func onReconnectFinished(_ handler: @escaping (CBPeripheral) -> Void) -> Self {
        self.onReconnectFinished = handler
        return self
    }
    
    @discardableResult
    func onMaxReconnectAttemptsReached(_ handler: @escaping (CBPeripheral) -> Void) -> Self {
        self.onMaxReconnectAttemptsReached = handler
        return self
    }

    // 更新 enableAutoReconnect 方法，支持设置最大重连次数和重连超时
    @discardableResult
    func enableAutoReconnect(_ enable: Bool, maxAttempts: Int = 3, timeout: TimeInterval = 10) -> Self {
        self.autoReconnect = enable
        self.maxReconnectAttempts = maxAttempts
        self.reconnectTimeout = timeout
        return self
    }
}
