//
//  TestListController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation
import HBSwiftKit
// MARK: - global var and methods

// MARK: - main class
class TestListController: ViewController {
    
    let items = ["Safari", "Modal", "Push", "PopRoot"]
    
    lazy var tableView: UITableView = {
        let _tableView = UITableView(frame: .zero, style: .plain)
        _tableView.backgroundColor = .white
        _tableView.registerCell(UITableViewCell.self)
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.rowHeight = 50
        return _tableView
    }()
    
    override func setupLayout() {
        super.setupLayout()
        self.naviBar.title = "Media Player"
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
    }
}

// MARK: - private mothods
extension TestListController { 
}

// MARK: - call backs
extension TestListController { 
}

// MARK: - delegate or data source
extension TestListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getReusableCell(UITableViewCell.self)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            navigator.show(provider: TestScene.safari(URL(string: "https://www.apple.com")!), sender: self)
        case 1:
            navigator.show(provider: TestScene.videoPlayController(url: "https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/feedback/67877d72e4b0604661da588b.mp4"), sender: self)
        case 2:
            navigator.show(provider: TestScene.webController(url: "https://www.apple.com", title: ""), sender: self, transition: .modal(type: .fullScreen))
        case 3:
            navigator.pop(sender: self, toRoot: true)
        default:
            break
        }
    }
}

// MARK: - other classes
