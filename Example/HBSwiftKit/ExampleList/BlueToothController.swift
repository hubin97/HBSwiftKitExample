//
//  BlueToothController.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/11/2.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation
import CoreBluetooth
import HBSwiftKit

// MARK: - global var and methods

// MARK: - main class
class BlueToothController: BaseViewController {

    let bleManager: BLEManager = {
        return BLEManager.shared
            .setDebugMode(true)
            .setLogTag("[BLEManager]: ")
            .enableAutoReconnect(true)
            .setMatchingStrategy(RegexMatchingStrategy(mode: .advertisementData([0xaa])))
            .setTargetServices([CBUUID(string: "AF00")])  // "AF00": 服务UUID
    }()
    
    var peripherals = [CBPeripheral]()
    lazy var listView: UITableView = {
        let listView = UITableView.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH - kNavBarAndSafeHeight - kBottomSafeHeight), style: .plain)
        listView.backgroundColor = .white
        listView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        listView.tableFooterView = UIView.init(frame: CGRect.zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 50
        return listView
    }()

    override func setupUi() {
        super.setupUi()
        self.view.backgroundColor = .white
        self.navigationItem.title = "蓝牙测试页"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "搜索", style: .plain, target: self, action: #selector(scanAction))
        self.view.addSubview(listView)   
        
        self.addBleObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 开始扫描
        bleManager.startScanning(timeout: 20)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 停止扫描
        bleManager.stopScanning()
    }
}

extension BlueToothController {

    func addBleObserver() {
        
        bleManager
//            .setDebugMode(true)
//            .setLogTag(Date().format(with: "HH:mm:ss") + " [BLEManager]: ")
//            .enableAutoReconnect(true)
//            .setMatchingStrategy(RegexMatchingStrategy(mode: .advertisementData([0xaa])))
//            .setTargetServices([CBUUID(string: "AF00")])  // "AF00": 服务UUID
//            .startScanning(timeout: 15)
            .setOnStateChanged { state in
                print("蓝牙状态更新: \(state.rawValue)")
            }
            .setOnPeripheralDiscovered {[weak self] peripheral in
                guard let self = self else { return }
                print("发现外设: \(peripheral.name ?? "未知"); 共: \(self.bleManager.discoveredPeripherals.map({ $0.name ?? "未知" }))")
                self.peripherals.append(peripheral)
                self.listView.reloadData()
            }
//            .setOnScanCompleted {[weak self] peripherals in
//                guard let self = self else { return }
//                print("扫描完成. 共发现 \(peripherals.count) 个外设, 共: \(self.bleManager.discoveredPeripherals.map({ $0.name ?? "未知" }))")
//            }
            .setOnScanStateChange {[weak self] state in
                guard let self = self else { return }
                print("扫描状态更新: \(state)")
                switch state {
                case .started:
                    break
                case .stopped:
                    print("扫描完成. 共发现 \(peripherals.count) 个外设, 共: \(self.bleManager.discoveredPeripherals.map({ $0.name ?? "未知" }))")
                }
            }
//            .setOnConnected {[weak self] peripheral in
//                guard let self = self else { return }
//                print("连接成功: \(peripheral.name ?? "未知")")
//                self.updatePreipherals(with: peripheral)
//            }
//            .setOnConnectedPeripherals { peripherals in
//                print("已连接的所有外设: \(peripherals.map({ "\($0.name ?? "" + " [" + $0.identifier.uuidString + "]" )" }))")
//            }
//            .setOnConnectionTimeout { peripheral in
//                //#warning("连接超时处理")
//                print("连接 \(peripheral.name ?? "未知") 超时")
//            }
            .setOnConnectionStateChange {[weak self] state, peripheral in
                guard let self = self else { return }
                self.updatePreipherals(with: peripheral)
                switch state {
                case .connecting(let peripheral):
                    print("连接中: \(peripheral.name ?? "未知")")
                case .connected(let peripheral):
                    print("连接成功: \(peripheral.name ?? "未知")")
                case .failed(let peripheral, let error):
                    print("连接失败: \(peripheral.name ?? "未知")，错误: \(error?.localizedDescription ?? "无")")
                case .timedOut(let peripheral):
                    print("连接超时: \(peripheral.name ?? "未知")")
                case .disconnected(let peripheral, let reason):
                     switch reason {
                     case .userInitiated:
                         print("用户主动断开设备: \(peripheral.name ?? "未知")")
                         // 不做重连
                     case .unexpected(let error):
                         print("设备异常断开: \(peripheral.name ?? "未知")，错误: \(error.localizedDescription)")
                         // 触发重连或其他逻辑
                     }
                }
            }
//            .setOnDisconnected {[weak self] peripheral, error  in
//                guard let self = self else { return }
//                self.updatePreipherals(with: peripheral)
//                if error != nil {
//                    print("断开连接: \(peripheral.name ?? "未知"), Error: \(error?.localizedDescription ?? "null")")
//                } else {
//                    print("用户主动断开连接: \(peripheral.name ?? "未知")")
//                }
//            }
            .onReconnectStarted { peripheral in
                print("重连开始: \(peripheral.name ?? "未知")")
            }
            .onReconnectFinished { peripheral in
                print("重连结束: \(peripheral.name ?? "未知")")
            }
            .onMaxReconnectAttemptsReached { peripheral in
                print("达到最大重连次数: \(peripheral.name ?? "未知")")
            }

            .setOnDataReceived { peripheral, data in
                print("收到数据: \(peripheral.name ?? "未知"). \(data.count) 字节")
            }
        
    }
}

// MARK: - private mothods
extension BlueToothController {

    @objc func scanAction() {
        bleManager.startScanning(timeout: 20)
    }
    
    func updatePreipherals(with peripheral: CBPeripheral) {
        self.peripherals.enumerated().forEach { (index, p) in
            if p.identifier == peripheral.identifier {
                self.peripherals[index] = peripheral
            }
        }
        self.listView.reloadData()
    }
}

// MARK: - delegate or data source
extension BlueToothController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        peripherals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let p = peripherals[indexPath.row]
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: NSStringFromClass(UITableViewCell.self))
        cell.textLabel?.text = "\(p.name ?? "")  [\(p.identifier.uuidString)]"
        cell.detailTextLabel?.text = stateTxt(p.state)
        switch p.state {
        case .connected:
            cell.detailTextLabel?.textColor = .green
        case .connecting:
            cell.detailTextLabel?.textColor = .brown
        default:
            cell.detailTextLabel?.textColor = .black
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let p = peripherals[indexPath.row]
        if p.state == .connected {
            bleManager.disconnect(p)
        } else {
            bleManager.connect(to: [peripherals[indexPath.row]], timeout: 10)
        }
    }
    
    func stateTxt(_ state: CBPeripheralState) -> String {
        return ["disconnected", "connecting", "connected", "disconnecting"][state.rawValue]
    }
}

// MARK: - other classes
class BleMeta {
    var name: String?
    var uuid: String?
    var state: CBPeripheralState?
    var stateTxt: String? {
        if let s = state {
            return ["disconnected", "connecting", "connected", "disconnecting"][s.rawValue]
        }
        return nil
    }
    init() {}
    convenience init(name: String?, uuid: String?, state: CBPeripheralState?) {
        self.init()
        self.name = name
        self.uuid = uuid
        self.state = state
    }
}
