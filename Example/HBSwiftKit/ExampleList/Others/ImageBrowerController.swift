//
//  ImageBrowerController.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/8/21.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation
import Kingfisher

// MARK: - global var and methods
/// String -> UIimage
private func imagePathToImage(imagePath: String) -> UIImage? {

    do {
        let data = try Data(contentsOf: URL(string: imagePath)!)
        return UIImage.init(data: data)
    } catch {
    }

    return nil
}

// MARK: - main class
class ImageBrowerController: ViewController {

    fileprivate let albumCol = 3  // 3列
    fileprivate let albumMinSpacing: CGFloat = 10

    lazy var snapshotModels: [SnapshotModel] = {
        let count = 17
        let path = "https://wt-oss-test.oss-cn-shenzhen.aliyuncs.com/pic/scene03.png"
        var models = [SnapshotModel]()
        for idx in 0..<count {
            let model = SnapshotModel()
            model.id = idx
            model.createTimeMs = Int(Date().timeIntervalSince1970)/10 + idx
            model.thumbnailPath = path
            model.photoPath = path
            models.append(model)
        }
        return models
    }()

    lazy var layout: UICollectionViewFlowLayout = {
        let albumItemWidth = (kScreenW - CGFloat(albumCol + 1) * albumMinSpacing - 2 * albumMinSpacing) / CGFloat(albumCol)
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsets(top: albumMinSpacing, left: 2 * albumMinSpacing, bottom: albumMinSpacing, right: 2 * albumMinSpacing)
        layout.minimumLineSpacing = albumMinSpacing
        layout.minimumInteritemSpacing = albumMinSpacing
        layout.itemSize = CGSize(width: albumItemWidth, height: albumItemWidth)
        return layout
    }()

    lazy var albumCollect: UICollectionView = {
        let collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(SnapshotItem.self, forCellWithReuseIdentifier: NSStringFromClass(SnapshotItem.self))
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()

    lazy var toolBar: IBToolBar = {
        let toolBar = IBToolBar(frame: CGRect.zero)
        toolBar.leftBtn.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        toolBar.rightBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return toolBar
    }()

    var isEditable: Bool? // 是否可编辑
    lazy var rightEditBtn: UIButton = {
        let _rightEditBtn = UIButton.init(type: .custom)
        _rightEditBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        _rightEditBtn.setTitle("选择", for: .normal)
        _rightEditBtn.setTitleColor(.black, for: .normal)
        _rightEditBtn.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        return _rightEditBtn
    }()
    
    override func setupLayout() {
        super.setupLayout()
        self.naviBar.title = "照片浏览器"
        self.naviBar.setRightView(rightEditBtn)
        self.view.addSubview(toolBar)
        self.view.addSubview(albumCollect)
        //self.albumCollect.reloadData()
        
        self.toolBar.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(kTabBarAndSafeHeight)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(kTabBarAndSafeHeight)
        }
        
        self.albumCollect.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom)
            make.bottom.equalTo(toolBar.snp.top)
            make.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - private mothods
extension ImageBrowerController {

}

// MARK: - call backs
extension ImageBrowerController {

    @objc func editAction() {
        self.isEditable = (self.isEditable == true) ? false: true
        self.rightEditBtn.setTitle((self.isEditable == true) ? "取消" :"选择", for: .normal)

        if self.isEditable == true { // 可编辑
            UIView.animate(withDuration: 0.3) {
                self.toolBar.snp.updateConstraints { make in
                    make.bottom.equalToSuperview()//.offset(kTabBarAndSafeHeight)
                }
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.toolBar.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().offset(kTabBarAndSafeHeight)
                }
                self.view.layoutIfNeeded()
            }

            // 取消后清空选中项
            snapshotModels.forEach { (model) in
                model.isSelected = false
            }
            updateSelectCount()
        }

        snapshotModels.forEach { (model) in
            model.isEditable = self.isEditable
        }

        albumCollect.reloadData()
    }

    @objc func shareAction() {
        print("to do share")

        let selectModels = self.snapshotModels.filter({ $0.isSelected == true })

        var activityItems = [UIImage]()
        selectModels.forEach { (model) in
            if let image = imagePathToImage(imagePath: model.photoPath ?? "") {
                activityItems.append(image)
            }
        }

        let activityVc = UIActivityViewController.init(activityItems: activityItems as [Any], applicationActivities: nil)
        // activityVc.excludedActivityTypes = [.postToFacebook, .postToTwitter, .postToWeibo, .message, .mail, .print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .airDrop, .openInIBooks]
        self.present(activityVc, animated: true, completion: nil)
        activityVc.completionWithItemsHandler = {(_, completed, _, _) -> Void in
            if completed == true {
                print("分享成功")
            }
            // 不能少
            activityVc.completionWithItemsHandler = nil
        }
    }

    @objc func deleteAction() {
        let alert = YTAlertView.init(title: "温馨提示", message: "照片将被删除，确认删除吗？")
        alert.addAction("取消", .lightGray, tapAction: nil)
        alert.addAction("确定") {
            let photoIdList = self.snapshotModels.filter({ $0.isSelected == true }).map({ $0.id! })
            print("to do delete\(photoIdList)")
            // self.deleteHandle(photoIdList: photoIdList)

            self.snapshotModels = self.snapshotModels.filter({ $0.isSelected == false })
            self.albumCollect.reloadData()
        }
        alert.show()
    }

}

extension ImageBrowerController: UpdateSelectCountDelegate {

    func updateSelectCount() {

        var count = 0
        snapshotModels.forEach { (model) in
            if model.isSelected == true {
                count += 1
            }
        }
        toolBar.countLabel.text = (count == 0) ? "选择照片" : "已选择\(count)张照片"
        toolBar.countLabel.textColor = (count == 0) ? .gray : .black
        toolBar.leftBtn.isEnabled = (count == 0) ? false: true
        toolBar.rightBtn.isEnabled = (count == 0) ? false: true
    }
}

// MARK: - delegate or data source
extension ImageBrowerController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        snapshotModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = snapshotModels[indexPath.row]
        let itemCell: SnapshotItem = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(SnapshotItem.self), for: indexPath) as! SnapshotItem
        itemCell.contentView.backgroundColor = .gray
        itemCell.model = model
        itemCell.updateDelegate = self
        return itemCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let model = snapshotModels[indexPath.row]
        print("####indexPath:\(indexPath.row)#######")
        print("model.id: \(model.id ?? 0)")
        print("model.createTimeMs: \(model.createTimeMs ?? 0)")
        print("model.thumbnailPath: \(model.thumbnailPath ?? "")")
        print("model.photoPath: \(model.photoPath ?? "")")

        let cell = collectionView.cellForItem(at: indexPath)
        var rect = cell?.convert(cell?.bounds ?? CGRect.zero, to: self.view) ?? CGRect.zero
        rect.origin.y += kNavBarAndSafeHeight

        let imagePaths = snapshotModels.map({ $0.photoPath ?? "" })
        let imageBrower = ImageBrower.init(loadMode: .imagePath, dataSource: imagePaths)
        // imageBrower.backgroundColor = .black
        // imageBrower.loadImagePaths(imagePaths: imagePaths, tapIndex: indexPath.row, originRect: rect)
        imageBrower.show()

    }
}

// MARK: - other classes
class SnapshotModel {

    var id: Int?
    var createTimeMs: Int?
    var photoPath: String?
    var thumbnailPath: String?

    var isEditable: Bool? = false
    var isSelected: Bool? = false

    /// 6月11日 ，2020 yyyy-MM-dd
    var date: String? {

        let timeInterVal = Int((createTimeMs ?? 0) / 1000)
        let date = Date.init(timeIntervalSince1970: TimeInterval(timeInterVal))
        let dateString = Wto_CalendarUtils.stringFromDate(date: date, format: "MM月dd日 ,yyyy")
        return dateString
    }
}

/// 选中计算更新代理
protocol UpdateSelectCountDelegate: AnyObject {
    func updateSelectCount()
}

class SnapshotItem: UICollectionViewCell {

    var model: SnapshotModel? {
        didSet {
            iconView.kf.setImage(with: URL.init(string: (model?.thumbnailPath ?? "")), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)

            markIconBtn.isHidden = (model?.isEditable == true) ? false : true
            markIconBtn.isSelected = (model?.isSelected == true) ? true: false
        }
    }

    weak var updateDelegate: UpdateSelectCountDelegate?
 
    lazy var iconView: UIImageView = {
        let _iconView = UIImageView()
        _iconView.contentMode = .scaleAspectFill
        _iconView.frame = self.bounds
        return _iconView
    }()
    
//    lazy var grayView: UIView = {
//        let _grayView = UIView()
//        _grayView.frame = self.bounds
//        _grayView.backgroundColor = UIColor(white: 0, alpha: 0.7)
//        _grayView.isHidden = true
//        return _grayView
//    }()
    
    lazy var markIconBtn: UIButton = {
        var _markIconBtn = UIButton(type: .custom)
        _markIconBtn.frame = self.bounds//CGRect(x: self.bounds.size.width - kScaleW(45), y: self.bounds.size.height - kScaleW(45), width: kScaleW(40), height: kScaleW(40))
        _markIconBtn.setImage(R.image.ib_unselect(), for: .normal)
        _markIconBtn.setImage(R.image.ib_select(), for: .selected)
//        markIconBtn.setBackgroundImage(UIImage(color: UIColor.init(white: 0, alpha: 0)), for: .normal)
//        markIconBtn.setBackgroundImage(UIImage(color: UIColor.init(white: 0, alpha: 0.3)), for: .selected)
        _markIconBtn.imageEdgeInsets = UIEdgeInsets(top: self.bounds.size.height - 25, left: self.bounds.size.width - 25, bottom: 0, right: 0)
        _markIconBtn.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        _markIconBtn.isSelected = false
        _markIconBtn.isHidden = true
        return _markIconBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setRectCorner(radiiSize: 4)
        self.contentView.addSubview(iconView)
//        self.contentView.addSubview(grayView)
        self.contentView.addSubview(markIconBtn)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func selectAction() {
        markIconBtn.isSelected = !markIconBtn.isSelected
        model?.isSelected = markIconBtn.isSelected
        updateDelegate?.updateSelectCount()
    }
}

// MARK: 底部工具栏
class IBToolBar: UIView {

    var leftBtn = UIButton.init(type: .custom)
    var rightBtn = UIButton.init(type: .custom)
    var countLabel = UILabel.init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 0.5))
        self.addSubview(lineView)
        lineView.backgroundColor = .lightGray

        self.addSubview(leftBtn)
        leftBtn.frame = CGRect(x: 20, y: 4.5, width: 40, height: 40)
        leftBtn.setImage(UIImage(named: "ib_share"), for: .normal)
        leftBtn.isEnabled = false

        self.addSubview(rightBtn)
        rightBtn.frame = CGRect(x: kScreenW - 60, y: 4.5, width: 40, height: 40)
        rightBtn.setImage(UIImage(named: "ib_remove"), for: .normal)
        rightBtn.isEnabled = false

        countLabel.frame = CGRect(x: 70, y: 4.5, width: kScreenW - 140, height: 40)
        self.addSubview(countLabel)
        countLabel.text = "选择照片"
        countLabel.font = UIFont.systemFont(ofSize: 18)
        countLabel.textColor = .gray
        countLabel.textAlignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
