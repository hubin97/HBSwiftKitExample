//
//  ViewController.swift
//  HBSwiftKitExample
//
//  Created by design on 2020/11/2.
//

import UIKit

//MARK: - main class
class ViewController: BaseViewController {

    lazy var dataArrays: [DemoRowModel] = {
        let datas = [DemoRowModel(title: "照片浏览器", dclass: ImageBrowerController()),
                     DemoRowModel(title: "日历选择器", dclass: CalendarPickerController()),
                     DemoRowModel(title: "日期选择器", dclass: DatePickerController()),
                     DemoRowModel(title: "数字选择器", dclass: NumberPickerController()),
                     DemoRowModel(title: "蓝牙测试页", dclass: BlueToothController())
                     ]
        return datas
    }()
    
    lazy var listView: UITableView = {
        let listView = UITableView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kNavBarAndSafeHeight - kBottomSafeHeight), style: .plain)
        listView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 50
        return listView
    }()
    
    override func setupUi() {
        super.setupUi()
        
        if let navi = self.navigationController as? BaseNavigationController {
            navi.leftBtnImage = UIImage(named: "navi_back_b")
        }
        title = "Example List"
        
        view.addSubview(listView)
        listView.reloadData()
    }
}

//MARK: - private mothods
extension ViewController {
    
}

//MARK: - call backs
extension ViewController {
    
}

//MARK: - delegate or data source
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArrays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataArrays[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataArrays[indexPath.row]
        if let tclass = model.class {
            self.navigationController?.pushViewController(tclass, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - other classes
class DemoRowModel {
    
    var title: String?
    var `class`: BaseViewController?
    
    init() {
    }
    
    convenience init(title: String?, dclass: BaseViewController?) {
        self.init()
        self.title = title
        self.class = dclass
    }
}
