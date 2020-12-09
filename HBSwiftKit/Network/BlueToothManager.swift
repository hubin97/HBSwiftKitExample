//
//  BlueToothManager.swift
//  HBSwiftKit
//
//  Created by hubin.h@wingto.cn on 2020/11/6.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation
import CoreBluetooth

//MARK: - global var and methods
/// 注意权限配置 NSBluetoothAlwaysUsageDescription
/// 管理单例
public let bleManager = BlueToothManager()

//MARK: - main class
public class BlueToothManager: NSObject {
    
    /// 匹配蓝牙外设前缀
    public var matchDPre: String?
    /// 匹配蓝牙外设UUID
    public var matchUUID: String?
    /// 匹配蓝牙外设UUID2
    public var matchUUID2: String?

    /// 回调搜索外设数组更新
    public var callBackAllPeripheralsUpdateBlock: (() -> ())?
    
    /// 回调外设连接状态更新
    public var callBackLinkStateUpdateBlock: (() -> ())?

    /// 系统蓝牙设备管理对象，可以把他理解为主设备，通过他，可以去扫描和链接外设
    lazy var centralManager: CBCentralManager = {
        // CBCentralManagerScanOptionAllowDuplicatesKey值为 No，表示不重复扫描已发现的设备
        let options = [CBCentralManagerOptionShowPowerAlertKey: "YES", CBCentralManagerScanOptionAllowDuplicatesKey: "NO"]
        let centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        return centralManager
    }()
    /// 保存外设数组
    public var allPeripherals = [CBPeripheral]()
    /// 特征值
    public var characteristcs: CBCharacteristic?
}

//MARK: - private mothods
extension BlueToothManager {
    
    /// 扫描外设
    public func scan() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /// 连接外设
    public func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    /// 断开外设连接
    public func disconnect(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    /// 断开所有连接
    public func disconnect() {
        centralManager.stopScan()
        guard allPeripherals.count > 0 else { return }
        _ = allPeripherals.filter({ $0.state == .connected }).map({ centralManager.cancelPeripheralConnection($0) })
    }
}

//MARK: - call backs
extension BlueToothManager {
    
}

//MARK: - delegate or data source
extension BlueToothManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //MARK: - CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let statelist = ["unknown", "resetting", "unsupported", "unauthorized", "poweredOff", "poweredOn"]
        print("centralstate:\(statelist[central.state.rawValue])")
        if central.state == .poweredOn {
            scan()
        } else {
            print("未开启蓝牙!")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil else {
            print("搜索到外设名UnKnown")
            return
        }
        print("开始搜索外设: \(peripheral.name ?? "UnKnown")")
        guard let matchDPre = matchDPre else {
            if allPeripherals.contains(peripheral) == false { allPeripherals.append(peripheral) }
            callBackAllPeripheralsUpdateBlock?()
            return
        }
        if peripheral.name?.hasPrefix(matchDPre) == true {
            if allPeripherals.contains(peripheral) == false { allPeripherals.append(peripheral) }
            callBackAllPeripheralsUpdateBlock?()
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("外设\(peripheral.name ?? "")连接成功")
        centralManager.stopScan()
        // 把已连接外设置顶🔝
        allPeripherals = allPeripherals.filter({ $0 != peripheral })
        allPeripherals.insert(peripheral, at: 0)
        callBackLinkStateUpdateBlock?()
        // 设置的peripheral委托CBPeripheralDelegate
        peripheral.delegate = self
        // 扫描外设Services，成功后会进入方法：didDiscoverServices
        peripheral.discoverServices(nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("外设\(peripheral.name ?? "")断开连接")
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("外设\(peripheral.name ?? "")连接失败")
    }
    
    //MARK: - CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let err = error {
            print("扫描到外设服务出错:\(err.localizedDescription)")
            return
        }
        print("扫描到外设服务:\(peripheral.name ?? ""),\(peripheral.services ?? [CBService]())")
        if let matchUUID = matchUUID {
            // => 扫描外设服务匹配协调头后会进入方法：didDiscoverDescriptorsFor service继续扫描特征
            _ = peripheral.services?.filter({ $0.uuid.isEqual(CBUUID(string: matchUUID)) }).map({ peripheral.discoverCharacteristics(nil, for: $0) })
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let err = error {
            print("扫描到外设特征出错:\(err.localizedDescription)")
            return
        }
        // => 设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
        _ = service.characteristics?.map({ peripheral.setNotifyValue(true, for: $0) })
        // => 读取Characteristic的值
        _ = service.characteristics?.map({ peripheral.readValue(for: $0) })
        // => 获取Characteristic的值，读到数据会进入方法：didUpdateValueFor characteristic
        _ = service.characteristics?.map({ peripheral.discoverDescriptors(for: $0) })
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let matchUUID2 = matchUUID2, let data = characteristic.value, characteristic.uuid.isEqual(CBUUID(string: matchUUID2)) {
            let string = String.init(data: data, encoding: .utf8) ?? ""
            print("外设特征: \(string)")
        }
    }
    
    /// 搜索到Characteristic的Descriptors
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("didDiscoverDescriptorsFor characteristic uuid: \(characteristic.uuid)")
        _ = characteristic.descriptors?.map({ print("descriptors uuid: \($0.uuid)") })
    }
}

//MARK: - other classes
