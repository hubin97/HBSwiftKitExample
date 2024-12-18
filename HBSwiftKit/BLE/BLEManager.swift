//
//  BLEManager.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/11/26.
//  Copyright © 2020 路特创新. All rights reserved.

//
// #1 链式实现
// 1. 蓝牙管理器 支持扫描开始结束; 连接状态,超时机制及通道就绪回调
// 2. 支持设置 自动重连, 重连次数, 重连超时
// 3. 支持自定义外设匹配策略
// 4. 支持设置目标服务UUID
// 5. 支持设置读,写及通知特征值UUID
// 6. 支持设置debug模式
// 7. 支持设置日志tag
// 8. 支持自定义外设广播包数据解析器
// 9. 支持多外设连接, 写入数据
// 10. 支持写入超时处理

// #2 Rx扩展
// 1. 消息序列化, 全局可订阅
// 2. 区分主题, 便于管理 x

// #3 问题点
// 1. 日志输出插入的时间不是实时的

import Foundation
import CoreBluetooth

// MARK: - global var and methods

/// 外设广播包数据
public struct BLEPeripheraData {
    public var advertisementData: [String : Any]
    public var rssi: NSNumber
}

// MARK: - main class
public class BLEManager: NSObject, BLEReconnectable, BLEWriteTimeoutHandler {

    public static let shared = BLEManager()

    // 开启debug模式
    private var debugMode = false
    // 插入日志标记
    private var logTag = "[BLEManager]: "
    
    // MARK: BLEReconnectable 协议属性
    var autoReconnect = false
    var maxReconnectAttempts = 3  // 最大重连次数
    var reconnectTimeout: TimeInterval = 10  // 重连超时
    var reconnectPhase: ((CBPeripheral, BLEReconnectState) -> Void)?
    var currentReconnectAttempts: [CBPeripheral: Int] = [:]
    
    // MARK: BLEWriteTimeoutHandler 协议属性
    var writeCmdLock = NSLock()
    var openWriteTimeout: Bool = false
    var withResponse: Bool = false
    var cmdComparisonRule: ((BLEWriteData, Data) -> Bool)?
    var peripheralQueues: [String: BLEPriorityQueue<BLEWriteData>] = [:]
    var writeTimeoutHandle: ((BLEWriteData) -> Void)?
    
    // MARK: Peripheral Data Parsing
    private var parser: (any BLEAdvDataParser)?
    private var onPeripheralDiscoveredWithParser: ((CBPeripheral, BLEPeripheraData, Any?) -> Void)?
    
    // MARK: Central Manager Delegate
    private var centralManager: CBCentralManager!
    private var onStateChanged: ((CBManagerState) -> Void)?
    
    private var onConnected: ((CBPeripheral) -> Void)?
    private var onConnectedPeripherals: (([CBPeripheral]) -> Void)?
    private var onDisconnected: ((CBPeripheral, Error?) -> Void)?
    private var onPeripheralDiscovered: ((CBPeripheral, BLEPeripheraData) -> Void)?
    
    private var onScanCompleted: (([CBPeripheral]) -> Void)?
    private var onConnectionTimeout: ((CBPeripheral) -> Void)?
    
    private var scanTimeoutWorkItem: DispatchWorkItem?
    // 兼容多设备连接超时
    private var connectionTimeoutTasks: [CBPeripheral: DispatchWorkItem] = [:]
    
    // 回调扫描状态
    private var onScanStateChange: ((BLEScanState) -> Void)?
    // 回调连接状态 (BLEReconnectable默认实现 外设状态变更也会关联到该回调)
    var onConnectionStateChange: ((BLEConnectionState, CBPeripheral) -> Void)?
      
    // 过滤条件
    // 用于设备匹配的策略，默认实现匹配所有设备
    private var matchingStrategy: BLEPeripheralMatching = DefaultMatchingStrategy()
    // 指定要连接的服务UUID
    private var targetServices: [CBUUID] = []
    
    // 读写操作
    // 读特征值UUID
    private var readCharUUID: CBUUID?
    // 写特征值UUID
    private var writeCharUUID: CBUUID?
    // notify特征值UUID
    private var notifyCharUUID: CBUUID?
    // 记录写特征值 (兼容多设备连接场景, 一个外设对应一个写特征值)
    var writeChars: [CBPeripheral: CBCharacteristic] = [:]

    /// 数据回调 (仅返回`BLECharValueUpdateResult` 成功的回调)
    private var onDataReceived: ((BLECharValueUpdateResult) -> Void)?

    // 通道就绪  特征值的回调, 读特征, 通知特征 已订阅; 写特征已记录
    private var onChannalReadyResult: ((BLEChannalReadyResult) -> Void)?
    // 数据回调
    private var onCharValueUpdateResult: ((BLECharValueUpdateResult) -> Void)?
    // 写入回调 (当写入类型为带响应时, 会有回调, 否则不会有回调)
    private var onWithResponseWriteResult: ((BLECharWriteResult) -> Void)?
      
    // 已发现的外设数组
    private var _discoveredPeripherals: [CBPeripheral] = []
    public var discoveredPeripherals: [CBPeripheral] {
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
    
    /// 判断是否已连接到指定外设
    public func isConnected(to peripheral: CBPeripheral) -> Bool {
        return connectedPeripherals.contains(peripheral)
    }
}

// MARK: - Central Manager Delegate
extension BLEManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        printLog("蓝牙状态更新: \(central.state.rawValue)")
        onStateChanged?(central.state)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if matchingStrategy.shouldConnect(to: peripheral, advertisementData: advertisementData) {
            if !_discoveredPeripherals.contains(peripheral) {
                _discoveredPeripherals.append(peripheral)
                
                printLog("发现符合规则的外设: \(peripheral.name ?? "未知")")
                if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
                    printLog("广播包数据: \(manufacturerData.map({ String(format: "%02x", $0) }).joined(separator: " "))")
                }
                
                let peripheraData = BLEPeripheraData(advertisementData: advertisementData, rssi: RSSI)
                // 常规外设发现回调
                onPeripheralDiscovered?(peripheral, peripheraData)

                // 是否设置了数据解析器
                if let parser = parser {
                    let parsedData = parser.parse(advertisementData: advertisementData)
                    onPeripheralDiscoveredWithParser?(peripheral, peripheraData, parsedData)
                }
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 清除该外设的超时任务
        connectionTimeoutTasks[peripheral]?.cancel()
        connectionTimeoutTasks.removeValue(forKey: peripheral)
        
        // 更新连接外设数组
        connectedPeripherals.append(peripheral)
        
        printLog("已连接到: \(peripheral.name ?? "未知")")
        
        onConnected?(peripheral)
        onConnectedPeripherals?(connectedPeripherals)
        onConnectionStateChange?(.connected(peripheral), peripheral)

        peripheral.delegate = self
        peripheral.discoverServices(targetServices.isEmpty ? nil : targetServices)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
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
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        printLog("连接失败: \(peripheral.name ?? "未知")，错误: \(error?.localizedDescription ?? "无")")
        onConnectionStateChange?(.failed(peripheral, error), peripheral)
        currentReconnectAttempts[peripheral] = (currentReconnectAttempts[peripheral] ?? 0) + 1
        // 尝试重连
        startReconnect(for: peripheral)
    }
    
    // MARK: Service Discovery
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            printLog("发现服务失败: \(error.localizedDescription)")
            return
        }
        
        if let services = peripheral.services {
            let charUUIDs = [readCharUUID, writeCharUUID, notifyCharUUID].compactMap { $0 }
            for service in services {
                // 如果设置了读写特征值UUID，则继续发现指定特征值
                if !charUUIDs.isEmpty {
                    peripheral.discoverCharacteristics(charUUIDs, for: service)
                } else {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error = error {
            printLog("发现特征值失败: \(error.localizedDescription)")
            let result = BLEChannalReadyResult.failure(peripheral, error)
            onChannalReadyResult?(result)
            onConnectionStateChange?(.onReady(result), peripheral)
            return
        }
        
        guard let characteristics = service.characteristics else { return }
       
        for characteristic in characteristics {
            // 读属性
            if characteristic.properties.contains(.read) && (readCharUUID == nil || characteristic.uuid == readCharUUID) {
                printLog("发现读特征值: \(characteristic.uuid)")
                peripheral.readValue(for: characteristic)
            }
            
            // 通知属性
            if characteristic.properties.contains(.notify) && (notifyCharUUID == nil || characteristic.uuid == notifyCharUUID) {
                printLog("订阅通知特征值: \(characteristic.uuid)")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            // 写属性分为带响应和不带响应
            if (characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse)) && (writeCharUUID == nil || characteristic.uuid == writeCharUUID) {
                printLog("记录写特征值: \(characteristic.uuid)")
                self.writeChars[peripheral] = characteristic
            }
            
            // 为每个特征发现描述符：didUpdateValueFor characteristic
            peripheral.discoverDescriptors(for: characteristic)
        }
        
        let result = BLEChannalReadyResult.success(peripheral, service)
        onChannalReadyResult?(result)
        onConnectionStateChange?(.onReady(result), peripheral)
    }
    
    // MARK: Descriptor Discovery (Optional) 描述符发现 一般用不上
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            printLog("发现描述符失败: \(error.localizedDescription)")
            return
        }
        
        guard let descriptors = characteristic.descriptors else { return }
        for descriptor in descriptors {
            printLog("发现描述符: \(descriptor.uuid)")
        }
    }
    
    // MARK: Data Handling
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            printLog("更新特征值失败: \(error.localizedDescription)")
            onCharValueUpdateResult?(.failure(peripheral, characteristic, error))
            return
        }
        if let data = characteristic.value {
            onDataReceived?(.success(peripheral, characteristic, data))
            onCharValueUpdateResult?(.success(peripheral, characteristic, data))
            
            // 如果开启写超时处理, 更新外设队列数据
            didUpdatePeripheralQueues(peripheral: peripheral, receiveData: data)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            printLog("写特征值失败: \(error.localizedDescription)")
            onWithResponseWriteResult?(.failure(peripheral, characteristic, error))
            return
        }
        onWithResponseWriteResult?(.success(peripheral, characteristic))
    }
}

// MARK: - Scanning / Connecting
extension BLEManager {
    
    // MARK: Scanning
    @discardableResult
    public func startScanning(timeout: TimeInterval? = nil) -> Self {
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
    
    public func stopScanning() {
        onScanStateChange?(.stopped)
        centralManager.stopScan()
        scanTimeoutWorkItem?.cancel()
        scanTimeoutWorkItem = nil
        printLog("扫描停止。")
    }
    
    // MARK: Connecting
    @discardableResult
    public func connect(to peripheral: CBPeripheral, options: [String: Any]? = nil, timeout: TimeInterval? = nil) -> Self {
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
    public func connect(to peripherals: [CBPeripheral], options: [String: Any]? = nil, timeout: TimeInterval? = nil) -> Self {
        peripherals.forEach { connect(to: $0, options: options, timeout: timeout) }
        return self
    }
    
    @discardableResult
    public func disconnect(_ peripheral: CBPeripheral) -> Self {
        centralManager.cancelPeripheralConnection(peripheral)
        return self
    }
    
    // MARK: Write Data
    @discardableResult
    public func wirteData(_ data: Data, for peripheral: CBPeripheral, type: CBCharacteristicWriteType = .withoutResponse) -> Self {
        guard let char = writeChars[peripheral] else {
            printLog("未找到可写特征值")
            return self
        }
        
        // 如果开启写超时处理, 使用队列处理
        if openWriteTimeout {
            let bleData = BLEWriteData(peripheral: peripheral, writeChar: char, data: data)
            writeData(bleData, withResponse: type == .withResponse)
            printLog("写入数据(\(bleData.requestId.uuidString)): \(bleData.data.map({ String(format: "%02x", $0) }).joined(separator: " "))")
        } else {
            peripheral.writeValue(data, for: char, type: type)
            printLog("写入数据(\(peripheral.identifier.uuidString)): \(data.map({ String(format: "%02x", $0) }).joined(separator: " "))")
        }
        return self
    }
}

// MARK: - Chainable Methods

// MARK: - Configs Setter
extension BLEManager {
    
    @discardableResult
    public func setDebugMode(_ isDebug: Bool) -> Self {
        self.debugMode = isDebug
        return self
    }
    
    @discardableResult
    public func setLogTag(_ tag: String) -> Self {
        self.logTag = tag
        return self
    }
    
    @discardableResult
    public func setMatchingStrategy(_ strategy: BLEPeripheralMatching) -> Self {
        self.matchingStrategy = strategy
        return self
    }
    
    @discardableResult
    public func setTargetServices(_ services: [CBUUID]) -> Self {
        self.targetServices = services
        return self
    }
    
    @discardableResult
    public func setReadCharUUID(_ uuid: CBUUID) -> Self {
        self.readCharUUID = uuid
        return self
    }

    @discardableResult
    public func setWriteCharUUID(_ uuid: CBUUID) -> Self {
        self.writeCharUUID = uuid
        return self
    }
    
    @discardableResult
    public func setNotifyCharUUID(_ uuid: CBUUID) -> Self {
        self.notifyCharUUID = uuid
        return self
    }
    
    @discardableResult
    public func setOpenWriteTimeout(_ open: Bool) -> Self {
        self.openWriteTimeout = open
        return self
    }
    
    @discardableResult
    public func setCmdComparisonRule(_ rule: @escaping (BLEWriteData, Data) -> Bool) -> Self {
        self.cmdComparisonRule = rule
        return self
    }
    
    @discardableResult
    public func setWriteTimeoutHandle(_ handler: @escaping (BLEWriteData) -> Void) -> Self {
        self.writeTimeoutHandle = handler
        return self
    }
}

// MARK: - Characteristic Value Callbacks
extension BLEManager {
    
    @discardableResult
    public func setOnChannalReadyResult(_ handler: @escaping (BLEChannalReadyResult) -> Void) -> Self {
        self.onChannalReadyResult = handler
        return self
    }
    
    @discardableResult
    public func setOnCharValueUpdateResult(_ handler: @escaping (BLECharValueUpdateResult) -> Void) -> Self {
        self.onCharValueUpdateResult = handler
        return self
    }
    
    /// 写入数据回调 (仅当写入类型为带响应时, 会有回调)
    @discardableResult
    public func setOnWithResponseWriteResult(_ handler: @escaping (BLECharWriteResult) -> Void) -> Self {
        self.onWithResponseWriteResult = handler
        return self
    }
}

// MARK: - State Change Callbacks
extension BLEManager {
    
    @discardableResult
    public func setOnStateChanged(_ handler: @escaping (CBManagerState) -> Void) -> Self {
        self.onStateChanged = handler
        return self
    }

    @discardableResult
    public func setOnScanStateChange(_ handler: @escaping (BLEScanState) -> Void) -> Self {
        self.onScanStateChange = handler
        return self
    }
    
    @discardableResult
    public func setOnConnectionStateChange(_ handler: @escaping (BLEConnectionState, CBPeripheral) -> Void) -> Self {
        self.onConnectionStateChange = handler
        return self
    }
    
    @discardableResult
    public func setOnDataReceived(_ handler: @escaping (BLECharValueUpdateResult) -> Void) -> Self {
        self.onDataReceived = handler
        return self
    }
    
    @discardableResult
    public func setOnConnected(_ handler: @escaping (CBPeripheral) -> Void) -> Self {
        self.onConnected = handler
        return self
    }
    
    @discardableResult
    public func setOnConnectedPeripherals(_ handler: @escaping ([CBPeripheral]) -> Void) -> Self {
        self.onConnectedPeripherals = handler
        return self
    }
    
    @discardableResult
    public func setOnDisconnected(_ handler: @escaping (CBPeripheral, Error?) -> Void) -> Self {
        self.onDisconnected = handler
        return self
    }
    
    @discardableResult
    public func setOnPeripheralDiscovered(_ handler: @escaping (CBPeripheral, BLEPeripheraData) -> Void) -> Self {
        self.onPeripheralDiscovered = handler
        return self
    }
    
    @discardableResult
    public func setOnScanCompleted(_ handler: @escaping ([CBPeripheral]) -> Void) -> Self {
        self.onScanCompleted = handler
        return self
    }
    
    @discardableResult
    public func setOnConnectionTimeout(_ handler: @escaping (CBPeripheral) -> Void) -> Self {
        self.onConnectionTimeout = handler
        return self
    }
}

// MARK: - Reconnectable 协议方法
extension BLEManager {

    @discardableResult
    public func onReconnectPhase(_ handler: @escaping (CBPeripheral, BLEReconnectState) -> Void) -> Self {
        self.reconnectPhase = handler
        return self
    }

    // 更新 enableAutoReconnect 方法，支持设置最大重连次数和重连超时
    @discardableResult
    public func enableAutoReconnect(_ enable: Bool, maxAttempts: Int = 3, timeout: TimeInterval = 10) -> Self {
        self.autoReconnect = enable
        self.maxReconnectAttempts = maxAttempts
        self.reconnectTimeout = timeout
        return self
    }
}

// MARK: - Advertisement Data Parser
extension BLEManager {
    
    @discardableResult
    public func setAdvertisementParser<P: BLEAdvDataParser>(_ parser: P) -> Self {
        self.parser = parser
        return self
    }
    
    /// 使用时需要指定解析器返回的具体类型
    ///
    /// 注意：此处的 data 参数类型为 Any?，需要在外部调用时指定具体的类型
    /// .setOnPeripheralDiscoveredWithParser { (p, pDataProvider, parse: String?) in }
    /// .setOnPeripheralDiscoveredWithParser { (p, pDataProvider, parse: [UInt8]]?) in }
    @discardableResult
    public func setOnPeripheralDiscoveredWithParser<T>(_ handler: @escaping (CBPeripheral, BLEPeripheraData, T?) -> Void) -> Self {
        self.onPeripheralDiscoveredWithParser = { peripheral, pdata, data in
            handler(peripheral, pdata, data as? T)
        }
        return self
    }
}
