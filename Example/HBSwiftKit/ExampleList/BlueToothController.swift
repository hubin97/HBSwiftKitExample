//
//  BlueToothController.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/11/2.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation
import CoreBluetooth

//MARK: - global var and methods

//MARK: - main class
class BlueToothController: BaseViewController {

    var dataArrays = [BleModel]()
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
        
        self.title = "蓝牙测试页"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "搜索", style: .plain, target: self, action: #selector(scanAction))
        
        view.addSubview(listView)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataArrays.removeAll()
        listView.reloadData()
        
        callBacks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bleManager.disconnect()
    }
}

//MARK: - private mothods
extension BlueToothController {
    
}

//MARK: - call backs
extension BlueToothController {
    
    @objc func scanAction() {
        bleManager.scan()
    }
    
    func callBacks() {
        
        bleManager.callBackAllPeripheralsUpdateBlock = { [weak self] in
            self?.dataArrays.removeAll()
            bleManager.allPeripherals.forEach { p in
                self?.dataArrays.append(BleModel.init(name: p.name, uuid: nil, state: p.state))
            }
            self?.listView.reloadData()
        }
        
        bleManager.callBackLinkStateUpdateBlock = { [weak self] in
            let p = bleManager.allPeripherals.filter({ $0.state == .connected }).first
            self?.dataArrays.forEach({ (model) in
                if model.name == p?.name {
                    model.state = p?.state
                }
            })
            self?.listView.reloadData()
        }
    }
}

//MARK: - delegate or data source
extension BlueToothController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArrays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataArrays[indexPath.row]
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: NSStringFromClass(UITableViewCell.self))
        cell.textLabel?.text = "\(model.name ?? "")  \(model.uuid ?? "")"
        cell.detailTextLabel?.text = model.stateTxt
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataArrays[indexPath.row]
        let p = bleManager.allPeripherals.filter({ $0.name == model.name }).first
        bleManager.connect(peripheral: p!)
    }
}

//MARK: - other classes
class BleModel {
    
    var name: String?
    var uuid: String?
    var state: CBPeripheralState?
    var stateTxt: String {
        return ["disconnected", "connecting", "connected", "disconnecting"][state!.rawValue]
    }
    
    init() {
    }
    
    convenience init(name: String?, uuid: String?, state: CBPeripheralState?) {
        self.init()
        self.name = name
        self.uuid = uuid
        self.state = state
    }
}
