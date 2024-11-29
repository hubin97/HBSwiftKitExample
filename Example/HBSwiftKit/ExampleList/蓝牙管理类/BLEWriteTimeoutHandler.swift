//
//  BLEWriteTimeoutHandler.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/11/27.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import CoreBluetooth

// MARK: - global var and methods

// ???: 当是writeWithoutResponse时, 是否超时, 应该由外部定义, 比如, 比较 didUpdate协议返回的数据是否一致

// 写入操作超时处理协议
protocol BLEWriteTimeoutHandler where Self: BLEManager {
    
    var writeCmdLock: NSLock { get }

    /// 开启写超时处理
    var openWriteTimeout: Bool { get set }
    /// 指令数据比较规则闭包
    var cmdComparisonRule: ((BLEWriteData, Data) -> Bool)? { get set }
    /// 写指令方式类型
    var withResponse: Bool { get set }
    /// 写超时处理回调
    var writeTimeoutHandle: ((BLEWriteData) -> Void)? { get set }

    /// 外设写队列 表, 使用外设UUID 做key
    var peripheralQueues: [String: BLEPriorityQueue<BLEWriteData>] { get set }
    
    func writeData(_ data: BLEWriteData, withResponse: Bool)
    func didUpdatePeripheralQueues(peripheral: CBPeripheral, receiveData data: Data)
    
    func removeQueue(for peripheral: CBPeripheral)
    func handleWriteTimeout(_ writeData: BLEWriteData)
}

// 扩展默认实现，可以根据具体需求来选择性重写
extension BLEWriteTimeoutHandler {
    
    // 获取或创建队列
    func getQueue(for peripheral: CBPeripheral) -> BLEPriorityQueue<BLEWriteData> {
        let uuidString = peripheral.identifier.uuidString
        if let queue = peripheralQueues[uuidString] {
            return queue
        }
        let newQueue = BLEPriorityQueue<BLEWriteData>()
        peripheralQueues[uuidString] = newQueue
        return newQueue
    }
    
    // 移除队列
    func removeQueue(for peripheral: CBPeripheral) {
        let uuidString = peripheral.identifier.uuidString
        peripheralQueues.removeValue(forKey: uuidString)
    }
    
    // 写数据逻辑
    func writeData(_ data: BLEWriteData, withResponse: Bool) {
        self.withResponse = withResponse
        var queue = getQueue(for: data.peripheral)
        queue.enqueue(data)
        
        let uuidString = data.peripheral.identifier.uuidString
        peripheralQueues[uuidString] = queue
        
        processNextCommand(for: data.peripheral)
    }
    
    // 处理下一条指令
    func processNextCommand(for peripheral: CBPeripheral) {
        writeCmdLock.lock()
        defer { writeCmdLock.unlock() }
        
        let uuidString = peripheral.identifier.uuidString
        guard let queue = peripheralQueues[uuidString], let writeData = queue.peek() else { return }
        printLog("队首指令: \(writeData.requestId), \(writeData.data.map { String(format: "%02X", $0) }.joined())")
        
        // 写数据到蓝牙外设
        let type: CBCharacteristicWriteType = self.withResponse ? .withResponse : .withoutResponse
        writeData.peripheral.writeValue(writeData.data, for: writeData.writeChar, type: type)

//        // 设置超时处理
//        if openWriteTimeout {
//            writeData.timer = Timer.scheduledTimer(withTimeInterval: writeData.timeout, repeats: false) { [weak self] _ in
//                if let queue = self?.peripheralQueues[uuidString], queue.contains(writeData) {
//                    self?.handleWriteTimeout(writeData)
//                }
//            }
//        }
        
        if openWriteTimeout {
            // 指令超时处理
            DispatchQueue.main.asyncAfter(deadline: .now() + writeData.timeout) {
                // 取延时后的最新队列; 如果此时倒计时开启的writeData和队列中的首元素 requestId 相同，说明没有发送过下一条指令，即当前指令发送超时了
                guard var lastQueue = self.peripheralQueues[uuidString], !lastQueue.isEmpty else { return }
                guard writeData.requestId == lastQueue.peek()?.requestId else { return }
                // 出队
                lastQueue.dequeue()
                self.peripheralQueues[uuidString] = lastQueue
                // 超时处理
                self.handleWriteTimeout(writeData)
                // 发送下一条指令
                self.processNextCommand(for: peripheral)
            }
        } else {
            // 发送下一条指令
            self.processNextCommand(for: peripheral)
        }
    }
    
    // 更新外设队列数据 跳过忽略超时处理
    func didUpdatePeripheralQueues(peripheral: CBPeripheral, receiveData data: Data) {
        guard self.openWriteTimeout else { return }
        
        // 获取当前队列的头部指令
        if var queue = peripheralQueues[peripheral.identifier.uuidString],
           let firstWriteData = queue.peek(),
           let comparisonRule = cmdComparisonRule {
            
            // 使用外部定义的比较规则进行匹配
            if comparisonRule(firstWriteData, data) {
                // 匹配成功，移除队列中对应的数据
                queue.dequeue()
                // 更新队列数据
                peripheralQueues[peripheral.identifier.uuidString] = queue
                // 处理下一条指令
                processNextCommand(for: peripheral)
            } else {
                printLog("指令数据不匹配, \(firstWriteData.data[3]) != \(data[3])")
            }
        }
    }
    
    // 默认超时处理
    func handleWriteTimeout(_ writeData: BLEWriteData) {
        print("指令超时回调: \(writeData.uuid) \(writeData.requestId.uuidString) \(writeData.data.map { String(format: "%02X", $0) }.joined())")
        writeTimeoutHandle?(writeData)
    }
}
