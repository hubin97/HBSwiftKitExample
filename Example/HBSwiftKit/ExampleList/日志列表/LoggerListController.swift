//
//  LoggerListController.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/30.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import CocoaLumberjack
//MARK: - global var and methods

//MARK: - main class
class LoggerListController: BaseViewController {

    var logFiles = [DDLogFileInfo]()
    lazy var dateFormatter: DateFormatter = {
        let _dateFormatter = DateFormatter.init()
        _dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        _dateFormatter.timeZone = TimeZone.current
        return _dateFormatter
    }()
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
        
        self.navigationItem.title = "日志列表"
        //LoggerManager.shared.launch()
        logFiles = LoggerManager.shared.fileLogger.logFileManager.sortedLogFileInfos
        //DDLogInfo("logFiles:\(logFiles.count)")
        view.addSubview(listView)
    }
}

//MARK: - private mothods
extension LoggerListController {
    
}

//MARK: - call backs
extension LoggerListController {
    
}

//MARK: - delegate or data source
extension LoggerListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        logFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = logFiles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        var logdate = dateFormatter.string(from: file.creationDate ?? Date())
        if indexPath.row == 0 {
            logdate = "最新" + logdate
        }
        cell.textLabel?.text = logdate
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVc = LoggerDetailController()
        detailVc.file = logFiles[indexPath.row]
        self.navigationController?.pushViewController(detailVc, animated: true)
    }
}


//MARK: - other classes
class LoggerDetailController: BaseViewController {

    var file: DDLogFileInfo?
    lazy var logTextView: UITextView = {
        let _logTextView = UITextView.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH - kNavBarAndSafeHeight - kBottomSafeHeight))
        _logTextView.isEditable = false
        return _logTextView
    }()
    override func setupUi() {
        super.setupUi()
        self.navigationItem.title = "日志详情"
        
        view.addSubview(logTextView)
        if let fpath = file?.filePath, let fdata = try? Data.init(contentsOf: URL.init(fileURLWithPath: fpath)) {
            logTextView.text = String(data: fdata, encoding: .utf8)
        }
    }
}
