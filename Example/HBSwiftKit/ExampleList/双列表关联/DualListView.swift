//
//  DualListView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/5/12.
//  Copyright © 2020 Wingto. All rights reserved.

/// 云图家庭区域选取双列表
import Foundation

//MARK: - global var and methods

//MARK: - main class
class FamilyAreaOptionsView: UIView, DualListDataSourceDelegate {
   
    lazy var contentView: UIView = {
        let contentView = UIView.init(frame: CGRect(x: -self.bounds.size.width, y: 0, width: self.bounds.size.width * 4/5, height: self.bounds.size.height))
        contentView.backgroundColor = .white
        return contentView
    }()

    /// 灰色蒙层
    lazy var grayView: UIButton = {
        let grayView = UIButton.init(type: .system)
        grayView.frame = self.bounds
        grayView.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        grayView.addTarget(self, action: #selector(hide), for: .touchUpInside)
        return grayView
    }()
    
    /// 工具栏
    lazy var managerBtn: UIButton = {
        let _managerBtn = UIButton.init(type: .custom)
        _managerBtn.frame = CGRect(x: 20, y: contentView.bounds.size.height - 55 - 60, width: contentView.bounds.size.width - 40, height: 55)
        _managerBtn.setTitle("家庭管理", for: .normal)
        _managerBtn.setTitleColor(.white, for: .normal)
        _managerBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        _managerBtn.setBackgroundImage(UIImage(color: .red), for: .normal)
        _managerBtn.setRectCorner(radiiSize: 55/2)
        //okBtn.setBackgroundImage(UIImage.init(color: .red), for: .highlighted)
        _managerBtn.addTarget(self, action: #selector(managerAction), for: .touchUpInside)
        return _managerBtn
    }()
    
    lazy var dualListView: DualListView = {
        let _dualListView = DualListView.init(frame: CGRect(x: 0, y: kNavBarAndSafeHeight, width: contentView.bounds.size.width, height: managerBtn.frame.minY - kNavBarAndSafeHeight))
        _dualListView.delegate = self
        return _dualListView
    }()
    
    lazy var titleLabel: UILabel = {
        let _titleLabel = UILabel.init(frame: CGRect(x: 20, y: kStatusBarHeight, width: contentView.bounds.size.width - 40, height: kNavBarHeight))
        _titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return _titleLabel
    }()
    
    lazy var lineView: UIView = {
        let _lineView = UIView.init(frame: CGRect(x: 20, y: titleLabel.frame.maxY - 1, width: contentView.bounds.size.width - 40, height: 1))
        _lineView.backgroundColor = UIColor(white: 0, alpha: 0.05)
        return _lineView
    }()
    
    var title: String? {
        didSet {
            titleLabel.text = "く\(title ?? "")"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        addSubview(grayView)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
        contentView.addSubview(managerBtn)
        contentView.addSubview(dualListView)
    }
    
    convenience init(data: [String: Any]?) {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func managerAction() {
        print("managerAction")
    }
    
    func didSelectedModel(mModel: DualListMasterModel?, dModel: DualListDetailModel?) {
        self.title = mModel?.title
        let content = "\(mModel?.title ?? "")●\(dModel?.title ?? "")"
        print(content)
    }
    
    @objc public func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.contentView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width * 4/5, height: self.bounds.size.height)
        }
    }
    
    @objc public func hide() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.frame = CGRect(x: -self.bounds.size.width, y: 0, width: self.bounds.size.width * 4/5, height: self.bounds.size.height)
        } completion: { (finish) in
            self.removeFromSuperview()
        }
    }
}



protocol DualListDataSourceDelegate: class {
    func didSelectedModel(mModel: DualListMasterModel? ,dModel: DualListDetailModel?)
}

class DualListView: UIView {

    var callbackDataBlock: ((_ mModel: DualListMasterModel?, _ dModel: DualListDetailModel?) -> ()?)?
    weak var delegate: DualListDataSourceDelegate?
    
    lazy var filterModels: [DualListMasterModel] = {
        let path = Bundle.main.path(forResource: "duallist", ofType: "json")
        let url = URL(fileURLWithPath: path ?? "")
        
        do {
            let json = try JSONSerialization.jsonObject(with: Data.init(contentsOf: url), options: .mutableContainers)
            if let dic = json as? Dictionary<String, Any>, let datas = dic["data"] as? [[String: Any]] {
                var models = [DualListMasterModel]()
                for dict in datas {
                    let secModel = DualListMasterModel.init()
                    secModel.title = dict["famlyname"] as? String
                    secModel.famlyId = dict["famlyId"] as? Int
                    secModel.authlev = dict["authlev"] as? Int
                    if let rowDatas = dict["areas"] as? [[String: Any]] {
                        var dmodels = [DualListDetailModel]()
                        for rowDict in rowDatas {
                            let rowModel = DualListDetailModel.init()
                            rowModel.title = rowDict["areaname"] as? String
                            rowModel.id = rowDict["areaId"] as? Int
                            dmodels.append(rowModel)
                        }
                        secModel.details = dmodels
                    }
                    models.append(secModel)
                }
                return models
            }
        } catch {
            print("tojsonErro: \(error)")
        }
        return []
    }()
    
    var selectMasterRow: Int = 0
    
    lazy var masterList: UITableView = {
        let _master = UITableView.init(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width/2, height: self.bounds.size.height), style: .plain)
        _master.register(DualListMasterCell.self, forCellReuseIdentifier: NSStringFromClass(DualListMasterCell.self))
        _master.dataSource = self
        _master.delegate = self
        _master.rowHeight = 55
        _master.separatorColor = UIColor(white: 0, alpha: 0.05)
        return _master
    }()
    
    
    lazy var detailList: UITableView = {
        let _detail = UITableView.init(frame: CGRect(x: self.bounds.size.width/2, y: 0, width: self.bounds.size.width/2, height: self.bounds.size.height), style: .plain)
        _detail.register(DualListDetailCell.self, forCellReuseIdentifier: NSStringFromClass(DualListDetailCell.self))
        _detail.dataSource = self
        _detail.delegate = self
        _detail.rowHeight = 55
        _detail.separatorColor = UIColor(white: 0, alpha: 0.05)
        return _detail
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(self.masterList)
        addSubview(self.detailList)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - private mothods
extension DualListView {
    
}

//MARK: - call backs
extension DualListView {
    
}

//MARK: - delegate or data source
extension DualListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == masterList ? filterModels.count: (filterModels[selectMasterRow].details?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mModel = filterModels[indexPath.row]
        if tableView == masterList {
            let masterCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DualListMasterCell.self), for: indexPath)
            let levFlag = (mModel.authlev == -1) ? "#": (mModel.authlev == 0 ? "!" : (mModel.authlev == 1 ? "@": "*"))
            masterCell.textLabel?.text = "\(levFlag) \(mModel.title ?? "")"
            masterCell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            return masterCell
        }
        let detailCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DualListDetailCell.self), for: indexPath)
        let dModel = filterModels[selectMasterRow].details?[indexPath.row]
        detailCell.textLabel?.text = dModel?.title
        detailCell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        return detailCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == masterList {
            selectMasterRow = indexPath.row
            detailList.reloadData()
            // 或者默认选第一个 detail ??
            let mModel = filterModels[selectMasterRow]
            self.callbackDataBlock?(mModel, nil)
            self.delegate?.didSelectedModel(mModel: mModel, dModel: nil)
        } else {
            let mModel = filterModels[selectMasterRow]
            let dModel = filterModels[selectMasterRow].details?[indexPath.row]
            print("mModel:\(mModel.title ?? "") id:\(mModel.famlyId ?? 0) lev:\(mModel.authlev ?? 0)")
            print("=>dModel:\(dModel?.title ?? "") id:\(dModel?.id ?? 0)")
            self.callbackDataBlock?(mModel, dModel)
            self.delegate?.didSelectedModel(mModel: mModel, dModel: dModel)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat(1)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 1))
    }
}

//MARK: - other classes
class DualListMasterModel {
    var title: String?
    var authlev: Int?
    var famlyId: Int?
    var details: [DualListDetailModel]?
}

class DualListDetailModel {
    var id: Int?
    var title: String?
}

class DualListMasterCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DualListDetailCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
