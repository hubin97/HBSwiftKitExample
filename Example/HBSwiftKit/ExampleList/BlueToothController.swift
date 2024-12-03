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
class BlueToothController: ViewController {

    let bleManager: BLEManager = {
        return BLEManager.shared
            .setDebugMode(true) // 开启调试模式, 打印日志
            .setLogTag("[BLEManager]: ") // 插入日志标记
            .enableAutoReconnect(true)   // 开启自动重连
            .setMatchingStrategy(RegexMatchingStrategy(mode: .advertisementData([0xaa, 0x01]))) // 匹配策略
            .setAdvertisementParser(MACParser()) // 广播包解析器 (MAC地址解析器, 由外部业务而定)
            .setTargetServices([CBUUID(string: "AF00")])  // "AF00": 服务UUID
            .setWriteCharUUID(CBUUID(string: "AF01"))     // "AF01": 写特征UUID
            .setNotifyCharUUID(CBUUID(string: "AF02"))    // "AF02": 通知特征UUID
            .setOpenWriteTimeout(true) // 开启写入超时处理
            .setCmdComparisonRule { cmdData, ackData in   // 指令超时使用比较规则
                let reqData = cmdData.data
                let success = reqData[0] == ackData[0] && reqData[1] == ackData[1] && reqData[3] == ackData[3]
                print("比较: \(success ? "成功" : "失败"), \(success ? "" : "\(reqData[3]) != \(ackData[3])")")
                return success
            }
    }()
    
    var peripherals = [CBPeripheral]()
    lazy var listView: UITableView = {
        let listView = UITableView.init(frame: CGRect(x: 0, y: kNavBarAndSafeHeight, width: kScreenW, height: kScreenH - kNavBarAndSafeHeight - kBottomSafeHeight), style: .plain)
        listView.backgroundColor = .white
        listView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        listView.tableFooterView = UIView.init(frame: CGRect.zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 50
        return listView
    }()
    
    lazy var rightButton: UIButton = {
        let _button = UIButton(type: .custom)
        _button.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
        _button.setTitle("搜索", for: .normal)
        _button.addTarget(self, action: #selector(scanAction), for: .touchUpInside)
        return _button
    }()

    override func setupLayout() {
        super.setupLayout()
        self.view.backgroundColor = .white
        self.naviBar.title = "蓝牙测试页"
        self.naviBar.setRightView(rightButton)
        self.view.addSubview(listView)   
        
        self.oberverMethod()
        //self.chainableMethod()
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

// MARK: - Rx
extension BlueToothController {
    
    func oberverMethod() {
        
        bleManager.rx.managerStateUpdate().subscribe(onNext: { state in
            print("蓝牙状态更新: \(state.rawValue)")
        }).disposed(by: rx.disposeBag)
        
        bleManager.rx.scanStateUpdate().subscribe(onNext: { [weak self] state in
            guard let self = self else { return }
            print("扫描状态更新: \(state)")
            switch state {
            case .started:
                break
            case .stopped:
                print("扫描完成. 共发现 \(self.peripherals.count) 个外设, 共: \(self.bleManager.discoveredPeripherals.map({ $0.name ?? "未知" }))")
            }
        }).disposed(by: rx.disposeBag)
        
//        bleManager.rx.peripheralDiscovered().subscribe(onNext: { [weak self] (peripheral, pDataProvider) in
//            //guard let self = self else { return }
//            if let manufacturerData = pDataProvider.advertisementData["kCBAdvDataManufacturerData"] as? Data {
//                let manufacturerBytes = [UInt8](manufacturerData).map({String(format: "%02x", $0).uppercased()})
//                print("常规发现外设: \(peripheral.name ?? "未知") 广播包: \(manufacturerBytes) 信号: \(pDataProvider.rssi)")
////                self.peripherals.append(peripheral)
////                self.listView.reloadData()
//            }
//        }).disposed(by: rx.disposeBag)
        
        bleManager.rx.peripheralDiscoveredWithParser().subscribe(onNext: { [weak self] (peripheral, pDataProvider, parse: String?) in
            guard let self = self else { return }
            if let data = parse, let manufacturerData = pDataProvider.advertisementData["kCBAdvDataManufacturerData"] as? Data {
                let manufacturerBytes = [UInt8](manufacturerData).map({String(format: "%02x", $0).uppercased()})
                print("指定发现外设: \(peripheral.name ?? "未知") 广播包: \(manufacturerBytes) 信号: \(pDataProvider.rssi) 解析Mac地址: \(data)")
                self.peripherals.append(peripheral)
                self.listView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
        
        bleManager.rx.connectStateUpdate().subscribe(onNext: { [weak self] state, peripheral in
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
                case .unexpected(let error):
                    print("设备异常断开: \(peripheral.name ?? "未知")，错误: \(error.localizedDescription)")
                }
            case .onReady(let result):
                switch result {
                case .success(let peripheral, _):
                    print("通道准备就绪: \(peripheral.name ?? "未知")")
                    
                    let cmd = ["AA", "55", "00", "F0", "04", "AA", "55", "11", "00", "FC"].map { UInt8($0, radix: 16)! }
                    bleManager.wirteData(Data(cmd), for: peripheral)
                case .failure(let peripheral, let error):
                    print("通道准备失败: \(peripheral.name ?? "未知")，错误: \(error.localizedDescription)")
                }
            }
        }).disposed(by: rx.disposeBag)
        
        bleManager.rx.reconnectPhaseUpdate().subscribe(onNext: { peripheral, state in
            switch state {
            case .started:
                print("重连开始: \(peripheral.name ?? "未知")")
            case .stopped(let result):
                print("重连停止: \(result == .success ? "成功" : "超时")")
            }
        }).disposed(by: rx.disposeBag)
        
        bleManager.rx.dataReceived().subscribe(onNext: { result in
            // 仅有成功的情况
            if case let .success(peripheral, _, data) = result {
                let hex = data.map { String(format: "%02X", $0) }
                print("收到数据: \(peripheral.name ?? "未知"). \(hex)")
            }
        }).disposed(by: rx.disposeBag)
        
        bleManager.rx.writeTimeout().subscribe(onNext: { data in
            print("写入超时处理: \(data.uuid). \(data.description)")
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: Chainable
extension BlueToothController {
    
    func chainableMethod() {
        
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
            .setOnPeripheralDiscoveredWithParser {[weak self] (peripheral, pDataProvider, parse: String?) in
                if let self = self, let data = parse, let manufacturerData = pDataProvider.advertisementData["kCBAdvDataManufacturerData"] as? Data {
                    let manufacturerBytes = [UInt8](manufacturerData).map({String(format: "%02x", $0).uppercased()})
                    print("发现外设: \(peripheral.name ?? "未知") 广播包: \(manufacturerBytes) 信号: \(pDataProvider.rssi) 解析Mac地址: \(data)")
                    self.peripherals.append(peripheral)
                    self.listView.reloadData()
                }
            }
//            .setOnPeripheralDiscovered {[weak self] peripheral, pDataProvider in
//                guard let self = self, let manufacturerData = pDataProvider.advertisementData["kCBAdvDataManufacturerData"] else { return }
//                print("发现外设: \(peripheral.name ?? "未知"), \(manufacturerData), \(pDataProvider.rssi)")
//                //print("共: \(self.bleManager.discoveredPeripherals.map({ $0.name ?? "未知" }))")
//                self.peripherals.append(peripheral)
//                self.listView.reloadData()
//            }
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
                    case .unexpected(let error):
                        print("设备异常断开: \(peripheral.name ?? "未知")，错误: \(error.localizedDescription)")
                    }
                case .onReady(let result):
                    switch result {
                    case .success(let peripheral, _):
                        print("通道准备就绪: \(peripheral.name ?? "未知")")
                        
                        let cmd = ["AA", "55", "00", "F0", "04", "AA", "55", "11", "00", "FC"].map { UInt8($0, radix: 16)! }
                        bleManager.wirteData(Data(cmd), for: peripheral)
                    case .failure(let peripheral, let error):
                        print("通道准备失败: \(peripheral.name ?? "未知")，错误: \(error.localizedDescription)")
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
            .onReconnectPhase { peripheral, state in
                switch state {
                case .started:
                    print("重连开始: \(peripheral.name ?? "未知")")
                case .stopped(let result):
                    print("重连停止: \(result == .success ? "成功" : "超时")")
                }
            }
//            .onMaxReconnectAttemptsReached { peripheral in
//                print("达到最大重连次数: \(peripheral.name ?? "未知")")
//            }
//            .setOnChannalReadyResult {[weak self] result in
//                guard let self = self else { return }
//                switch result {
//                case .success(let peripheral, let service):
//                    print("通道准备就绪: \(peripheral.name ?? "未知") \(service.characteristics?.count ?? 0) 个")
//
//                    //let cmd = [0xAA, 0x55, 0x00]
//                    let cmd = ["AA", "55", "00", "F0", "04", "AA", "55", "11", "00", "FC"].map { UInt8($0, radix: 16)! }
//                    bleManager.wirteData(Data(cmd), for: peripheral)
//                case .failure(let peripheral, let error):
//                    print("通道准备失败: \(peripheral.name ?? "未知")，错误: \(error.localizedDescription)")
//                }
//            }
//            .setOnCharWriteResult { result in
//                switch result {
//                case .success(let peripheral, _):
//                    print("写入成功: \(peripheral.name ?? "未知")")
//                case .failure(let peripheral, _, let error):
//                    print("写入失败: \(peripheral.name ?? "未知"), Error: \(error.localizedDescription)")
//                }
//            }
            .setOnDataReceived { result in
                // 仅有成功的情况
                if case let .success(peripheral, _, data) = result {
                    let hex = data.map { String(format: "%02X", $0) }
                    print("收到数据: \(peripheral.name ?? "未知"). \(hex)")
                }
            }
            .setCmdComparisonRule { cmdData, ackData in
                let reqData = cmdData.data
                let success = reqData[0] == ackData[0] && reqData[1] == ackData[1] && reqData[3] == ackData[3]
                print("比较: \(success ? "成功" : "失败"), \(success ? "" : "\(reqData[3]) != \(ackData[3])")")
                return success
            }
//            .setOnCharValueUpdateResult { result in
//                switch result {
//                case .success(let peripheral, _, let data):
//                    let hex = data.map { String(format: "%02X", $0) }
//                    print("特征值更新: \(peripheral.name ?? "未知"). \(hex)")
//                case .failure(let peripheral, _, let error):
//                    print("特征值更新失败: \(peripheral.name ?? "未知"), Error: \(error.localizedDescription)")
//                }
//            }
            .setWriteTimeoutHandle { data in
                print("写入超时处理: \(data.uuid). \(data.requestId.uuidString)")
            }
    }
    
    func cmdWriteTest(for peripheral: CBPeripheral) {
        let cmd = ["AA", "55", "00", "F0", "04", "AA", "55", "11", "00", "FC"].map { UInt8($0, radix: 16)! }
        
        /// 临时测试指令
        let cmdx = ["AA", "55", "00", "0A", "04", "AA", "55", "11", "00", "FC"].map { UInt8($0, radix: 16)! }

        self.bleManager.wirteData(Data(cmd), for: peripheral)

        if cnt > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
                self?.cmdWriteTest(for: peripheral)
                
                if cnt % 3 == 0 {
                    self?.bleManager.wirteData(Data(cmdx), for: peripheral)
                }
                cnt -= 1
            }
        }
    }
}
var cnt = 40

// MARK: - private mothods
extension BlueToothController {

    @objc func scanAction() {
        let sheet = UIAlertController.init(title: "", message: "选择操作方式", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction.init(title: "开始扫描", style: .default, handler: { [weak self] _ in
            self?.bleManager.startScanning(timeout: 20)
        }))
        sheet.addAction(UIAlertAction.init(title: "下发指令F0", style: .default, handler: { [weak self] _ in
            let cmd = ["AA", "55", "00", "F0", "04", "AA", "55", "11", "00", "FC"].map { UInt8($0, radix: 16)! }
            if let p = self?.peripherals.first(where: { $0.state == .connected }) {
                self?.bleManager.wirteData(Data(cmd), for: p)
            }
        }))
        sheet.addAction(UIAlertAction.init(title: "模拟超时下发指令F0", style: .default, handler: { [weak self] _ in
//            if let p = self?.peripherals.first {
//                self?.cmdWriteTest(for: p)
//            }
            self?.peripherals.forEach { p in
                self?.cmdWriteTest(for: p)
            }
        }))
        
        self.present(sheet, animated: true, completion: nil)
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
