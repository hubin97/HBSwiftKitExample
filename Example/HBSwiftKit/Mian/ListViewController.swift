//
//  ViewController.swift
//  HBSwiftKitExample
//
//  Created by design on 2020/11/2.
//

import UIKit
import GDPerformanceView_Swift
import HBSwiftKit
import Router

// MARK: - main class
class ListViewController: ViewController, ViewModelProvider {
    typealias ViewModelType = ListViewModel
    
    lazy var listView: UITableView = {
        let listView = UITableView.init(frame: CGRect.zero, style: .plain)
        listView.backgroundColor = .white
        listView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        listView.tableFooterView = UIView.init(frame: CGRect.zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 50
        return listView
    }()

    override func setupLayout() {
        super.setupLayout()
        view.addSubview(listView)
        naviBar.title = "Example List"
        naviBar.leftView?.isHidden = true
        
        listView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PerformanceMonitor.shared().start()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
}

// MARK: - delegate or data source
extension ListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = vm.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.contentView.backgroundColor = .white
        cell.textLabel?.text = model.title
        cell.textLabel?.textColor = .black
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = vm.items[indexPath.row]
        switch item {
        case .imageBrower:
            let vc = ImageBrowerController()
            navigationController?.pushViewController(vc, animated: true)
        case .calendar:
            let vc = CalendarController()
            navigationController?.pushViewController(vc, animated: true)
        case .datePicker:
            let vc = DatePickerController()
            navigationController?.pushViewController(vc, animated: true)
        case .numberPicker:
            let vc = NumberPickerController()
            navigationController?.pushViewController(vc, animated: true)
        case .blueTooth:
            let vc = BlueToothController()
            navigationController?.pushViewController(vc, animated: true)
        case .easyAdScroll:
            let vc = EasyAdScrollController()
            navigationController?.pushViewController(vc, animated: true)
        case .mapLocation:
            let vc = MapLocationController()
            navigationController?.pushViewController(vc, animated: true)
        case .videoTest:
            let vc = VideoTestController()
            navigationController?.pushViewController(vc, animated: true)
        case .mqtt:
            let vc = MQTTTestController()
            navigationController?.pushViewController(vc, animated: true)
        case .mediaList:
            navigator.show(provider: AppScene.mediaList, sender: self)
        case .routerTest:
            navigator.show(provider: TestScene.testList, sender: self)
        }
    }
}
