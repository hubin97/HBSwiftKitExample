//
//  LoggerListController.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/30.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import CocoaLumberjack

// MARK: - main class
class LoggerListController: ViewController {

    open lazy var logFiles: [DDLogFileInfo] = {
        return LoggerManager.shared.fileLogger.logFileManager.sortedLogFileInfos
    }()

//    open lazy var dateFormatter: DateFormatter = {
//        let _dateFormatter = DateFormatter.init()
//        _dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        _dateFormatter.timeZone = TimeZone.current
//        return _dateFormatter
//    }()
    
    open lazy var listView: UITableView = {
        let listView = UITableView.init(frame: CGRect(x: 0, y: kNavBarAndSafeHeight, width: kScreenW, height: kScreenH - kNavBarAndSafeHeight), style: .plain)
        listView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        listView.tableFooterView = UIView.init(frame: CGRect.zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 50
        return listView
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.naviBar.title = "日志列表"
        view.addSubview(listView)
        LoggerManager.shared.removeEntrance()
        // DDLogInfo("LoggerManager LogFiles Count:\(logFiles.count)")
    }

    deinit {
        LoggerManager.shared.entrance()
    }
}

// MARK: - private mothods
extension LoggerListController {
    
}

// MARK: - call backs
extension LoggerListController {
    
}

// MARK: - delegate or data source
extension LoggerListController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        logFiles.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = logFiles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        var logdate = (file.creationDate ?? Date()).format()
        if indexPath.row == 0 {
            logdate = "最新" + logdate
        }
        cell.textLabel?.text = logdate
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVc = LoggerDetailController()
        detailVc.file = logFiles[indexPath.row]
        self.navigationController?.pushViewController(detailVc, animated: true)
    }
}

// MARK: - other classes
class LoggerDetailController: ViewController {

    var file: DDLogFileInfo?
    open lazy var logTextView: UITextView = {
        let _logTextView = UITextView.init(frame: CGRect(x: 0, y: kNavBarAndSafeHeight, width: kScreenW, height: kScreenH - kNavBarAndSafeHeight - kBottomSafeHeight))
        _logTextView.isEditable = false
        return _logTextView
    }()
    
    lazy var bottomButton: UIButton = {
        let _bottomItem = UIButton(type: .custom)
        _bottomItem.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        _bottomItem.setTitle("底部", for: .normal)
        _bottomItem.setTitleColor(.black, for: .normal)
        _bottomItem.addTarget(self, action: #selector(scrollToBottom), for: .touchUpInside)
        return _bottomItem
    }()
    
    lazy var fileButton: UIButton = {
        let _fileButton = UIButton(type: .custom)
        _fileButton.frame = CGRect(x: 44 + 12, y: 0, width: 44, height: 44)
        _fileButton.setTitle("导出", for: .normal)
        _fileButton.setTitleColor(.black, for: .normal)
        _fileButton.addTarget(self, action: #selector(saveToFile), for: .touchUpInside)
        return _fileButton
    }()
    
    lazy var titleView: UIView = {
        let _titleView = UIView(frame: CGRect(x: 0, y: 0, width: 88 + 12, height: 44))
        _titleView.addSubview(bottomButton)
        _titleView.addSubview(fileButton)
        return _titleView
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.naviBar.title = "日志详情"
        self.naviBar.setRightView(titleView)

        view.addSubview(logTextView)
        if let fpath = file?.filePath, let fdata = try? Data.init(contentsOf: URL.init(fileURLWithPath: fpath)) {
            logTextView.text = String(data: fdata, encoding: .utf8)
        }
    }

    @objc func scrollToBottom() {
        self.logTextView.scrollRangeToVisible(NSRange(location: self.logTextView.text.count - 1, length: 1))
    }

    @objc func saveToFile() {
        guard let fpath = file?.filePath else { return }
        let fUrl = URL.init(fileURLWithPath: fpath)
        let documentVc = UIDocumentPickerViewController.init(url: fUrl, in: .exportToService)
        documentVc.delegate = self
        documentVc.modalPresentationStyle = .pageSheet
        self.navigationController?.present(documentVc, animated: true, completion: nil)
    }
}

extension LoggerDetailController: UIDocumentPickerDelegate {

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first, let auth = urls.first?.startAccessingSecurityScopedResource(), auth else {
            print("授权失败")
            return
        }
        // 通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        let fileCoordinator = NSFileCoordinator.init()
        var error: NSError?
        fileCoordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &error) { newUrl in
            let fileName = newUrl.lastPathComponent
            print("文件名" + fileName)
        }
        urls.first?.stopAccessingSecurityScopedResource()
    }
}
