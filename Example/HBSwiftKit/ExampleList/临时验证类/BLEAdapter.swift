//
//  BLEAdapter.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2023/3/25.
//  Copyright © 2020 静逸青空. All rights reserved.

import Foundation
import CoreBluetooth

enum BLECentralState: String {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
    
    static var centralStates: [BLECentralState] {
        return [.unknown, .resetting, .unsupported, .unauthorized, .poweredOff, .poweredOn]
    }
}

protocol BLEAdapterDelegate: AnyObject {

    /// 更新蓝牙状态
    func updateCentral(state: BLECentralState)

    /// 更新已发现的外设
    func updateDiscover(peripherals: [CBPeripheral])

    /// 外设已连接
    func didConnect(peripheral: CBPeripheral)

    /// 发现服务, 并指定匹配的uuid
    func discoverServices(peripheral: CBPeripheral, characteristicOf targetUUID: (_ UUID: String) -> Void)
    
    /// 发现特征
    func discoverCharacteristicsFor(peripheral: CBPeripheral, service: CBService, error: Error?)
    
    /// 数据更新
    func didUpdateValueFor(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)
    
    /// 可以开始写入数据
    func startWriteData()
}

extension BLEAdapterDelegate {
    
    func updateCentral(state: BLECentralState) {}
    func updateDiscover(peripherals: [CBPeripheral]) {}
    func didConnect(peripheral: CBPeripheral) {}
    func discoverServices(peripheral: CBPeripheral, characteristicOf targetUUID: (_ UUID: String) -> Void) {}
    func discoverCharacteristicsFor(peripheral: CBPeripheral, service: CBService, error: Error?) {}
    func didUpdateValueFor(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?) {}
    func startWriteData() {}
}

// MARK: - main class
class BLEAdapter: NSObject {
    
    weak var delegate: BLEAdapterDelegate?
    
    static let shared = BLEAdapter()

    /// 系统蓝牙设备管理对象，可以把他理解为主设备，通过他，可以去扫描和链接外设
    lazy var centralManager: CBCentralManager = {
        // CBCentralManagerScanOptionAllowDuplicatesKey值为 NO，表示不重复扫描已发现的设备
        // 存在情况, 被其他设备已连接的, 发现不了, 应该排除在外 ???
        let options = [CBCentralManagerOptionShowPowerAlertKey: "YES", CBCentralManagerScanOptionAllowDuplicatesKey: "NO"]
        let _centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        return _centralManager
    }()
    /// 中心 状态
    var centralState: BLECentralState = .poweredOff
    /// 外设数组
    var peripherals: [CBPeripheral] = []
    /// 指定外设 (保留标记的外设)
    var target_peripheral: CBPeripheral?
    /// 可写特征
    var write_characteristic: CBCharacteristic?
    
}

// MARK: - private mothods
extension BLEAdapter {
   
    /// 扫描外设
    func scan() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    /// 连接外设
    func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    /// 断开外设连接
    func disconnect(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    /// 断开所有连接
    func disconnect() {
        centralManager.stopScan()
        guard peripherals.count > 0 else { return }
        peripherals.filter({ $0.state == .connected }).forEach({ centralManager.cancelPeripheralConnection($0) })
    }
    
    /// 当前已连接的外设
    func peripheral() -> CBPeripheral? {
        return peripherals.first(where: { $0.state == .connected })
    }
}

// MARK: - call backs
extension BLEAdapter {
}

// MARK: - delegate or data source
extension BLEAdapter: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state = BLECentralState.centralStates[central.state.rawValue]
        print("centralstate:\(state.rawValue)")
        if central.state != .poweredOn {
            print("蓝牙未开启!")
        }
        self.centralState = state
        self.delegate?.updateCentral(state: state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let pName = peripheral.name else { return }
        print("搜索到新外设: \(pName) => \(RSSI) => advertisementData\(advertisementData)")
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
        delegate?.updateDiscover(peripherals: peripherals)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("外设\(peripheral.name ?? "")连接成功")
        delegate?.didConnect(peripheral: peripheral)
        centralManager.stopScan()
        // 设置的peripheral委托CBPeripheralDelegate
        peripheral.delegate = self
        // 扫描外设Services，成功后会进入方法：didDiscoverServices
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("外设\(peripheral.name ?? "")断开连接")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("外设\(peripheral.name ?? "")连接失败")
    }
    
    //MARK: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let err = error {
            print("扫描到外设服务出错:\(err.localizedDescription)")
            return
        }
        print("扫描到外设服务:\(peripheral.name ?? ""),\(peripheral.services ?? [CBService]())")
        // => 扫描外设服务匹配协调头后会进入方法：didDiscoverDescriptorsFor service继续扫描特征
        peripheral.services?.forEach({ peripheral.discoverCharacteristics(nil, for: $0) })
//        delegate?.discoverServices(peripheral: peripheral, characteristicOf: { uuid in
//            peripheral.services?.filter({ $0.uuid.isEqual(CBUUID(string: uuid)) }).forEach({ peripheral.discoverCharacteristics(nil, for: $0) })
//        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let err = error {
            print("扫描到外设特征出错:\(err.localizedDescription)")
        }
        delegate?.discoverCharacteristicsFor(peripheral: peripheral, service: service, error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        delegate?.didUpdateValueFor(peripheral: peripheral, characteristic: characteristic, error: error)
    }
    
    /// 搜索到Characteristic的Descriptors
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        //guard characteristic.descriptors?.first(where: { $0.uuid.isEqual(reqCharacterUUID) }) != nil else { return }
        guard let p = self.peripheral(), p == peripheral else { return }
        /// 判断有 可写 权限
        if (characteristic.properties.rawValue & CBCharacteristicProperties.write.rawValue != 0) {
            print("@@@@@@此处写数据到设备:\(characteristic.uuid.uuidString)")
            self.write_characteristic = characteristic
            delegate?.startWriteData()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            print("写入数据出错:\(err.localizedDescription)")
            return
        }
        print("写入数据成功!")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            print("didUpdateNotification Error:\(err.localizedDescription)")
            return
        }
        print("didUpdateNotificationStateFor: \(characteristic)")
    }
}

// MARK: - other classes
