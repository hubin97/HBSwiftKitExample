//
//  ViewController.swift
//  HBSwiftKitExample
//
//  Created by design on 2020/11/2.
//

import UIKit
import GDPerformanceView_Swift
import HBSwiftKit

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
        let model = vm.items[indexPath.row]
        if let tclass = model.class {
            self.navigationController?.pushViewController(tclass, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
