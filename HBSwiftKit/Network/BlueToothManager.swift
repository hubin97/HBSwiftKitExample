//
//  BlueToothManager.swift
//  HBSwiftKit
//
//  Created by hubin.h@wingto.cn on 2020/11/6.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation
import CoreBluetooth

//MARK: - global var and methods

//MARK: - main class
class BlueToothManager: NSObject {
    
    /// 匹配蓝牙外设前缀
    public var matchDPre: String?
    /// 匹配蓝牙外设UUID
    public var matchUUID: String?
    /// 匹配蓝牙外设UUID2
    public var matchUUID2: String?

    /// 管理单例
    static public let manager = BlueToothManager()
    /// 系统蓝牙设备管理对象，可以把他理解为主设备，通过他，可以去扫描和链接外设
    //var centralManager: CBCentralManager?
    lazy var centralManager: CBCentralManager = {
        let options = [CBCentralManagerOptionShowPowerAlertKey: "YES"]
        let centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        return centralManager
    }()
    /// 保存外设数组
    var allPeripherals: [CBPeripheral]?
    /// 特征值
    var characteristcs: CBCharacteristic?
}

//MARK: - private mothods
extension BlueToothManager {
    
    func scan() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func disconnect() {
        guard let peripherals = allPeripherals else { return }
        peripherals.filter({ $0.state == .connected }).map({ centralManager.cancelPeripheralConnection($0) })
    }
}

//MARK: - call backs
extension BlueToothManager {
    
}

//MARK: - delegate or data source
extension BlueToothManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let statelist = ["unknown", "resetting", "unsupported", "unauthorized", "poweredOff", "poweredOn"]
        print("centralstate:\(statelist[central.state.rawValue])")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let matchDPre = matchDPre else {
            if allPeripherals?.contains(peripheral) == false { allPeripherals?.append(peripheral) }
            return
        }
        if peripheral.name?.hasPrefix(matchDPre) == true {
            if allPeripherals?.contains(peripheral) == false { allPeripherals?.append(peripheral) }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("外设\(peripheral.name)连接成功")
        centralManager.stopScan()
        // 把已连接外设置顶🔝
        allPeripherals = allPeripherals?.filter({ $0 != peripheral })
        allPeripherals?.insert(peripheral, at: 0)
        
        // 设置的peripheral委托CBPeripheralDelegate
        peripheral.delegate = self
        // 扫描外设Services，成功后会进入方法：didDiscoverServices
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("外设\(peripheral.name)断开连接")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("外设\(peripheral.name)连接失败")
    }
    
    //MARK: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let err = error {
            print("扫描到外设服务出错:\(err.localizedDescription)")
            return
        }
        print("扫描到外设服务:\(peripheral.name),\(peripheral.services)")
        if let matchUUID = matchUUID {
            // => 扫描外设服务匹配协调头后会进入方法：didDiscoverDescriptorsFor service继续扫描特征
            peripheral.services?.filter({ $0.uuid.isEqual(CBUUID(string: matchUUID)) }).map({ peripheral.discoverCharacteristics(nil, for: $0) })
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let err = error {
            print("扫描到外设特征出错:\(err.localizedDescription)")
            return
        }
        // => 设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
        service.characteristics?.map({ peripheral.setNotifyValue(true, for: $0) })
        // => 读取Characteristic的值
        service.characteristics?.map({ peripheral.readValue(for: $0) })
        // => 获取Characteristic的值，读到数据会进入方法：didUpdateValueFor characteristic
        service.characteristics?.map({ peripheral.discoverDescriptors(for: $0) })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let matchUUID2 = matchUUID2, let data = characteristic.value, characteristic.uuid.isEqual(CBUUID(string: matchUUID2)) {
            let string = String.init(data: data, encoding: .utf8)
            print("外设特征: \(characteristic)")
        }
    }
    
    /// 搜索到Characteristic的Descriptors
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("didDiscoverDescriptorsFor characteristic uuid: \(characteristic.uuid)")
        characteristic.descriptors?.map({ print("descriptors uuid: \($0.uuid)") })
    }
}

//MARK: - other classes
