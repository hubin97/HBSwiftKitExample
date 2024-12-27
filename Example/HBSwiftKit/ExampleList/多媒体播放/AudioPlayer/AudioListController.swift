//
//  AudioListController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class AudioListController: ViewController {
    
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
        self.naviBar.title = "Audio Player"
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - private mothods
extension AudioListController { 
}

// MARK: - call backs
extension AudioListController { 
}

// MARK: - delegate or data source
extension AudioListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getReusableCell(UITableViewCell.self)
        //cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

// MARK: - other classes
