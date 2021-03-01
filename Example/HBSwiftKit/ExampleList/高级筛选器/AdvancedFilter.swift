//
//  AdvancedFilter.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/2/26.
//  Copyright © 2020 Wingto. All rights reserved.

import UIKit
import Foundation

//MARK: - global var and methods

//MARK: - main class
class AdvancedFilter: UIView {
    
    var filterModels = [AdvancedFilterSecModel]()
    
    lazy var contentView: UIView = {
        let contentView = UIView.init(frame: CGRect(x: self.bounds.size.width, y: 0, width: self.bounds.size.width * 4/5, height: self.bounds.size.height))
        contentView.backgroundColor = .white
        return contentView
    }()
    
    /// 工具栏
    lazy var toolView: UIView = {
        let toolView = UIView.init(frame: CGRect(x: 0, y: contentView.bounds.size.height - kBottomSafeHeight - 48, width: contentView.bounds.size.width, height: 48))
        toolView.backgroundColor = .lightGray
        let resetBtn = UIButton.init(type: .custom)
        toolView.addSubview(resetBtn)
        resetBtn.frame = CGRect(x: 0, y: 0, width: toolView.bounds.size.width/2, height: toolView.bounds.size.height)
        resetBtn.setTitle("重置", for: .normal)
        resetBtn.setTitleColor(.black, for: .normal)
        resetBtn.setBackgroundImage(UIImage.init(color: .lightGray), for: .normal)
        resetBtn.setBackgroundImage(UIImage.init(color: .gray), for: .highlighted)
        resetBtn.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        
        let okBtn = UIButton.init(type: .custom)
        toolView.addSubview(okBtn)
        okBtn.frame = CGRect(x: toolView.bounds.size.width/2, y: 0, width: toolView.bounds.size.width/2, height: toolView.bounds.size.height)
        okBtn.setTitle("确定", for: .normal)
        okBtn.setTitleColor(.white, for: .normal)
        okBtn.setBackgroundImage(UIImage.init(color: .systemPink), for: .normal)
        okBtn.setBackgroundImage(UIImage.init(color: .red), for: .highlighted)
        okBtn.addTarget(self, action: #selector(okAction), for: .touchUpInside)
        return toolView
    }()
    
    lazy var listView: UITableView = {
        let listView = UITableView.init(frame: CGRect(x: 0, y: kTopSafeHeight, width: contentView.bounds.size.width, height: contentView.bounds.size.height - kTopSafeHeight - kBottomSafeHeight - self.toolView.bounds.height), style: .grouped)
        listView.backgroundColor = .white
        listView.register(AdvancedFilterFlowCell.self, forCellReuseIdentifier: NSStringFromClass(AdvancedFilterFlowCell.self))
        listView.tableHeaderView = tableHeaderView
        listView.tableFooterView = UIView.init(frame: CGRect.zero)
        listView.estimatedRowHeight = 60
        listView.separatorColor = .clear
        listView.dataSource = self
        listView.delegate = self
        return listView
    }()
    
    lazy var tableHeaderView: UIView = {
        let tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: contentView.bounds.size.width, height: 60))
        let titleLabel = UILabel.init(frame: CGRect(x: 20, y: 15, width: contentView.bounds.size.width - 40, height: 30))
        tableHeaderView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.text = "高级筛选"
        return tableHeaderView
    }()
    
    /// 灰色蒙层
    lazy var grayView: UIView = {
        let grayView = UIView.init(frame: self.bounds)
        grayView.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        return grayView
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        addSubview(grayView)
        addSubview(contentView)
        contentView.addSubview(toolView)
        contentView.addSubview(listView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - private mothods
extension AdvancedFilter {
    
    public func show() {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(self)
        }
        UIView.animate(withDuration: 0.3) {
            self.contentView.frame = CGRect(x: self.bounds.size.width/5, y: 0, width: self.bounds.size.width * 4/5, height: self.bounds.size.height)
        }
    }
    
    public func hide() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.frame = CGRect(x: self.bounds.size.width, y: 0, width: self.bounds.size.width * 4/5, height: self.bounds.size.height)
        } completion: { (finish) in
            self.removeFromSuperview()
        }
    }
    
    /// 计算行高 限定规则 最多5行
    func getRowHeight(with section: Int) -> CGFloat {
        let secModel = filterModels[section]
        var rowNum = (secModel.rowModels.count % 3 == 0) ? secModel.rowModels.count / 3: secModel.rowModels.count / 3 + 1
        rowNum = rowNum > 5 ? 5: rowNum
        let padding: CGFloat = 7.5
        let itemWidth = (self.listView.bounds.size.width - 4 * padding)/3.0
        let itemHeight = itemWidth/2.5
        let rowHeight = CGFloat(rowNum) * itemHeight + CGFloat(rowNum + 1) * padding
        return rowHeight
    }
}

//MARK: - call backs
extension AdvancedFilter {
    
    @objc func resetAction() {
        print("resetAction")
        _ = filterModels.map({ $0.rowModels.map({ $0.isSelected = false } )})
        self.listView.reloadData()
    }
    
    @objc func okAction() {
        print("okAction")
        hide()
        
        //
        var params = [[String: [String]]]()
        filterModels.forEach { (secModel) in
            let selModels = secModel.rowModels.filter({ $0.isSelected == true })
            if selModels.count > 0 {
                params.append([secModel.sectitle: selModels.map({ $0.rowtitle })])
            }
        }
        print("result:\(params)")
        // result:[["类型": ["单色灯", "色温灯"]], ["所在房间": ["卧室1", "走廊1", "玄关2", "客厅3"]], ["设备属性": ["开关", "色温", "颜色", "亮度"]]]
    }
}

//MARK: - delegate or data source
extension AdvancedFilter: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let secModel = filterModels[section]
        return secModel.isExpanded == true ? 1: 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let secModel = filterModels[indexPath.section]
        secModel.cellHeight = getRowHeight(with: indexPath.section)
        secModel.isMultiPiker = (secModel.sectitle == "添加日期") ? false: true
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(AdvancedFilterFlowCell.self), for: indexPath) as! AdvancedFilterFlowCell
        cell.secModel = secModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let secModel = filterModels[section]
        let secHeaderView = AdvancedFilterSecHeader.init(frame: CGRect(x: 0, y: 0, width: self.listView.bounds.size.width, height: 55))
        secHeaderView.model = secModel
        secHeaderView.delegate = self
        return secHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getRowHeight(with: indexPath.section)
    }
}

extension AdvancedFilter: AdvancedFilterSecHeaderDelegate {
    
    func updateHeaderExpand(isExpanded: Bool) {
        self.listView.reloadData()
    }
}

//MARK: - other classes
class AdvancedFilterSecModel {
    var sectitle: String = ""
    /// cell行高
    var cellHeight: CGFloat = 0
    /// 是否可多选
    var isMultiPiker: Bool? = false
    var rowModels: [AdvancedFilterRowModel] = []
    var isExpanded: Bool? = false
}

class AdvancedFilterRowModel {
    var rowtitle: String = ""
    var isSelected: Bool? = false
}

protocol AdvancedFilterSecHeaderDelegate: class {
    func updateHeaderExpand(isExpanded: Bool)
}

class AdvancedFilterSecHeader: UIView {
    
    var model: AdvancedFilterSecModel? {
        didSet {
            titleLabel.text = model?.sectitle
            iconView.transform = CGAffineTransform.init(rotationAngle: model?.isExpanded == true ? -.pi/2: .pi/2)
        }
    }
    
    weak var delegate: AdvancedFilterSecHeaderDelegate?
    private var ctlBtn = UIButton.init(type: .system)
    private var titleLabel = UILabel()
    private var iconView = UIImageView()
    private var lineView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(ctlBtn)
        addSubview(lineView)
        addSubview(titleLabel)
        addSubview(iconView)
        
        self.backgroundColor = .white
        
        ctlBtn.frame = self.bounds
        ctlBtn.addTarget(self, action: #selector(ctlAction), for: .touchUpInside)
        
        lineView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 1)
        titleLabel.frame = CGRect(x: 20, y: 0, width: frame.size.width * 3/4, height: frame.size.height)
        iconView.frame = CGRect(x: frame.size.width - 35, y: (frame.size.height - 15)/2, width: 15, height: 15)
        
        lineView.backgroundColor = UIColor(white: 0, alpha: 0.05)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        iconView.image = UIImage(named: "next_month_normal")
        iconView.transform = CGAffineTransform.init(rotationAngle: .pi/2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func ctlAction() {
        model?.isExpanded = !(model?.isExpanded ?? false)
        delegate?.updateHeaderExpand(isExpanded: model?.isExpanded ?? false)
    }
}

class AdvancedFilterFlowCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var secModel: AdvancedFilterSecModel? {
        didSet {
            dataCollection.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 4/5, height: secModel?.cellHeight ?? 0)
            dataCollection.reloadData()
        }
    }
    
    lazy var layout: UICollectionViewFlowLayout = {
        // 3列
        let padding: CGFloat = 7.5
        let itemWidth = (UIScreen.main.bounds.size.width * 4/5 - 6 * padding)/3.0
        let itemHeight = itemWidth/2.5
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: padding, left: 2*padding, bottom: padding, right: 2*padding)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        return layout
    }()
    
    lazy var dataCollection: UICollectionView = {
        let dataCollection = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        dataCollection.backgroundColor = .clear
        dataCollection.register(AdvancedFilterFlowItem.self, forCellWithReuseIdentifier: "item")
        dataCollection.dataSource = self
        dataCollection.delegate = self
        return dataCollection
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(dataCollection)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: flow data source / delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        secModel?.rowModels.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let rowModel = secModel?.rowModels[indexPath.item]
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! AdvancedFilterFlowItem
        item.rowModel = rowModel
        return item
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rowModel = secModel?.rowModels[indexPath.item]
        rowModel?.isSelected = (rowModel?.isSelected == true) ? false: true
        if secModel?.isMultiPiker == true {
            dataCollection.reloadItems(at: [indexPath])
        } else {
            _ = secModel?.rowModels.map({ $0.isSelected = false })
            rowModel?.isSelected = true
            dataCollection.reloadSections(IndexSet(integer: indexPath.section))
        }
    }
}

class AdvancedFilterFlowItem: UICollectionViewCell {
    
    var rowModel: AdvancedFilterRowModel? {
        didSet {
            titleLabel.text = rowModel?.rowtitle
            titleLabel.textColor = (rowModel?.isSelected == true) ? .white: .gray
            contentView.backgroundColor = (rowModel?.isSelected == true) ? .red: UIColor(white: 0, alpha: 0.05)
        }
    }
    
    fileprivate var titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.setRectCorner(radiiSize: 5)
        contentView.backgroundColor = UIColor(white: 0, alpha: 0.05)
        contentView.addSubview(titleLabel)
        titleLabel.frame = self.bounds
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
