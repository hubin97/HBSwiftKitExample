//
//  BlueToothManager.swift
//  HBSwiftKit
//
//  Created by hubin.h@wingto.cn on 2020/11/6.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation
import CoreBluetooth

/// 注意权限配置 NSBluetoothAlwaysUsageDescription
//MARK: - global var and methods
public typealias BLEManager = BlueToothManager

public protocol BLEManagerDelegate: AnyObject {
    /// 回调中心设备连接状态更新
    func updateCentralManagerState(central: CBCentralManager)
    /// 回调外设连接状态更新
    func updateCBPeripheralState(peripheral: CBPeripheral)
    /// 回调搜索外设数组更新
    func updateDiscoveredPeripherals(peripherals: [CBPeripheral])
    /// 回调搜索到的单个外设
    func updateDiscoveredPeripheral(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber)
}

//MARK: - main class
public class BlueToothManager: NSObject {

    /// 管理单例
    public static let shared = BlueToothManager()
    /// 匹配蓝牙外设前缀, 不为空时, allPeripherals匹配所有符合条件的外设
    public var matchDPre: String?
    /// 匹配蓝牙外设UUID
    public var matchUUID: String?
    /// 匹配蓝牙外设UUID2
    public var matchUUID2: String?

    public weak var delegate: BLEManagerDelegate?

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
        self.delegate?.updateCentralManagerState(central: central)
        if central.state == .poweredOn {
            scan()
        } else {
            print("未开启蓝牙!")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let pName = peripheral.name else { return }
        self.delegate?.updateDiscoveredPeripheral(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
        guard !allPeripherals.contains(peripheral) else { return }
        print("搜索到新外设: \(pName) => \(RSSI) => advertisementData\(advertisementData)")
        // 有前缀匹配要求, 按条件匹配
        if let matchDPre = matchDPre {
            if pName.hasPrefix(matchDPre) {
                allPeripherals.append(peripheral)
            }
        } else {
            allPeripherals.append(peripheral)
        }
        self.delegate?.updateDiscoveredPeripherals(peripherals: allPeripherals)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("外设\(peripheral.name ?? "")连接成功")
        self.delegate?.updateCBPeripheralState(peripheral: peripheral)
        centralManager.stopScan()
        // 把已连接外设置顶🔝
        allPeripherals = allPeripherals.filter({ $0 != peripheral })
        allPeripherals.insert(peripheral, at: 0)
        //callBackLinkStateUpdateBlock?()
        // 设置的peripheral委托CBPeripheralDelegate
        peripheral.delegate = self
        // 扫描外设Services，成功后会进入方法：didDiscoverServices
        peripheral.discoverServices(nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("外设\(peripheral.name ?? "")断开连接")
        self.delegate?.updateCBPeripheralState(peripheral: peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("外设\(peripheral.name ?? "")连接失败")
        self.delegate?.updateCBPeripheralState(peripheral: peripheral)
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
            peripheral.services?.filter({ $0.uuid.isEqual(CBUUID(string: matchUUID)) }).forEach({ peripheral.discoverCharacteristics(nil, for: $0) })
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let err = error {
            print("扫描到外设特征出错:\(err.localizedDescription)")
            return
        }
        service.characteristics?.forEach({ characteristic in
            // => 设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
            peripheral.setNotifyValue(true, for: characteristic)
            // => 读取Characteristic的值
            peripheral.readValue(for: characteristic)
            // => 获取Characteristic的值，读到数据会进入方法：didUpdateValueFor characteristic
            peripheral.discoverDescriptors(for: characteristic)
        })
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let matchUUID2 = matchUUID2, let data = characteristic.value, characteristic.uuid.isEqual(CBUUID(string: matchUUID2)) {
            let string = String.init(data: data, encoding: .utf8) ?? ""
            print("外设特征: \(string)")
        }
    }
    
    /// 搜索到Characteristic的Descriptors
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        //print("didDiscoverDescriptorsFor characteristic uuid: \(characteristic.uuid)")
        characteristic.descriptors?.forEach({ print("didDiscoverDescriptorsFor characteristic uuid: \($0.uuid)") })
    }
}
