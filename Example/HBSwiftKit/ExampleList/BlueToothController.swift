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

    var bleManager: BLEManager {
        let _bleManager = BLEManager.shared
        _bleManager.delegate = self
        return _bleManager
    }
    var dataArrays = [BleMeta]()
    lazy var listView: UITableView = {
        let listView = UITableView.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH - kNavBarAndSafeHeight - kBottomSafeHeight), style: .plain)
        listView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        listView.tableFooterView = UIView.init(frame: CGRect.zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 50
        return listView
    }()

    override func setupUi() {
        super.setupUi()
        self.navigationItem.title = "蓝牙测试页"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "搜索", style: .plain, target: self, action: #selector(scanAction))
        view.addSubview(listView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataArrays.removeAll()
        listView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bleManager.disconnect()
    }
}

// MARK: - private mothods
extension BlueToothController {

    @objc func scanAction() {
        bleManager.scan()
        printLog("scan")
    }
}

// MARK: - call backs
extension BlueToothController: BLEManagerDelegate {
    func updateCentralManagerState(central: CBCentralManager) {
        print("updateCentralManagerState => \(central.state)")
    }

    func updateCBPeripheralState(peripheral: CBPeripheral) {
        let pMeta = BleMeta(name: peripheral.name, uuid: peripheral.identifier.uuidString, state: peripheral.state)
        self.dataArrays.forEach({ $0.state = ($0.uuid == peripheral.identifier.uuidString ? .connected: .disconnected) })
        self.dataArrays = self.dataArrays.filter({ $0.state != .connected})
        self.dataArrays.insert(pMeta, at: 0)
        self.listView.reloadData()
    }

    func updateDiscoveredPeripherals(peripherals: [CBPeripheral]) {

    }

    func updateDiscoveredPeripheral(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        guard let pName = peripheral.name else { return }
        guard !self.dataArrays.map({ $0.name ?? "" }).contains(pName) else { return }
        self.dataArrays.append( BleMeta(name: peripheral.name, uuid: peripheral.identifier.uuidString, state: peripheral.state) )
        self.listView.reloadData()
    }
}

// MARK: - delegate or data source
extension BlueToothController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArrays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataArrays[indexPath.row]
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: NSStringFromClass(UITableViewCell.self))
        cell.textLabel?.text = "\(model.name ?? "")  [\(model.uuid ?? "")]"
        cell.detailTextLabel?.text = model.stateTxt
        switch model.state {
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
        let model = dataArrays[indexPath.row]
        model.state = .connecting
        tableView.reloadRows(at: [indexPath], with: .automatic)
//        let p = dataArrays.filter({ $0.name == model.name }).first
//        bleManager.connect(peripheral: p.)
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
