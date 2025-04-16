//
//  ImageBrower.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/8/21.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation
import Kingfisher

// MARK: - global var and methods
extension ImageBrower {
    
    public enum Mode {
        /// URLPath
        case imageObject
        /// URLPath
        case imagePath
    }
}

// MARK: - main class
open class ImageBrower: UIView {

    public typealias CallBackPageBlock = (_ pageIndex: Int) -> Void
    /// 默认值
    let lineSpacing: CGFloat = 0 // 间隙

    var loadMode: ImageBrower.Mode = .imageObject
    var imageModels = [ImageBrowerModel]()

    var originRect = CGRect()
    var tapGes: UITapGestureRecognizer!
    // 当前页下标
    var currentPage = 0
    public var callBackLastPage: CallBackPageBlock?
    /// 是否显示多图下标
    var isShowIndexView = false
    
    /// 缩放比例
    var showMinZoomScale: CGFloat = 1
    var showMaxZoomScale: CGFloat = 3
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return layout
    }()

    lazy var albumCollect: UICollectionView = {
        let collection = UICollectionView.init(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collection.register(ImageBrowerItem.self, forCellWithReuseIdentifier: NSStringFromClass(ImageBrowerItem.self))
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .black
        collection.isPagingEnabled = true
        return collection
    }()

    lazy var indexLabel: UILabel = {
        let _indexLabel = UILabel(frame: CGRect(x: (kScreenW - 60)/2, y: kStatusBarHeight + 20, width: 60, height: 30))
        _indexLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        _indexLabel.textAlignment = .center
        _indexLabel.textColor = .white
        _indexLabel.backgroundColor = UIColor(white: 0, alpha: 0.4)
        _indexLabel.layer.masksToBounds = true
        _indexLabel.layer.cornerRadius = 4
        _indexLabel.isHidden = true
        return _indexLabel
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)

        addSubview(albumCollect)
        addSubview(indexLabel)
        
        tapGes = UITapGestureRecognizer.init(target: self, action: #selector(hide))
        albumCollect.addGestureRecognizer(tapGes)

        // ImageCache.default.clearMemoryCache()
        /// 设置内存可缓存容量 设定值为 像素数 设定为1, 强制写入磁盘
        // 有闪退问题 data (CacheSerializer.swift:0)
        // ImageCache.default.maxMemoryCost = 1024 * 1024 * 10
    }
    
    ///  初始化
    /// - Parameters:
    ///   - loadMode:  加载模式
    ///   - dataSource: 数据源
    ///   - isShowIndexView: 是否显示下标
    ///   - tapIndex: 点击下标
    ///   - originRect: 原始位置
    public convenience init(loadMode: ImageBrower.Mode, dataSource: [Any], isShowIndexView: Bool = false, tapIndex: Int = 0, originRect: CGRect = CGRect(x: UIScreen.main.bounds.size.width/2 - 0.5, y: UIScreen.main.bounds.size.height/2 - 0.5, width: 1, height: 1)) {
        self.init(frame: UIScreen.main.bounds)

        self.loadMode = loadMode
        self.originRect = originRect
        self.currentPage = tapIndex
        self.isShowIndexView = isShowIndexView
        
        switch loadMode {
        case .imageObject:
            self.imageModels = dataSource.compactMap({ $0 as? UIImage }).map({ ImageBrowerModel(mode: .imageObject, image: $0 ) })
        case .imagePath:
            self.imageModels = dataSource.compactMap({ $0 as? String }).map({ ImageBrowerModel(mode: .imagePath, path: $0 ) })
        }
        
        // 开启下标并且大于1张时显示
        self.indexLabel.isHidden = !(isShowIndexView && dataSource.count > 1)
        self.indexLabel.text = String(format: "%02d/%02d", 1, self.imageModels.count)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - private mothods
extension ImageBrower {

    /// 移除点击hide手势
    public func removeTapHideGes() {
        self.albumCollect.removeGestureRecognizer(tapGes)
    }

    /// 设置最小缩放比例, 默认1
    public func setMinZoomScale(_ scale: CGFloat) -> Self {
        self.showMinZoomScale = scale
        return self
    }
    
    /// 设置最大缩放比例, 默认3
    public func setMaxZoomScale(_ scale: CGFloat) -> Self {
        self.showMaxZoomScale = scale
        return self
    }
    
    /// 设置缩放比例 默认1, 3
    public func setZoomScale(_ min: CGFloat, _ max: CGFloat) -> Self {
        self.showMinZoomScale = min
        self.showMaxZoomScale = max
        return self
    }
}

// MARK: - call backs
extension ImageBrower {

    @objc public func show() {
        self.albumCollect.reloadData()
        // 这个地方的方向待确认
        self.albumCollect.scrollToItem(at: IndexPath.init(item: self.currentPage, section: 0), at: .centeredHorizontally, animated: true)

        DispatchQueue.main.async {
            UIApplication.shared.delegate?.window??.addSubview(self)
        }

//        self.alpha = 0
//        self.tapIconView?.frame = originRect
//        UIView.animate(withDuration: 0.3) {
//            self.alpha = 1
//            self.tapIconView?.frame = UIScreen.main.bounds
//        }
    }

    @objc public func hide() {
        self.removeFromSuperview()
        self.callBackLastPage?(currentPage)

//        self.alpha = 1
//        self.tapIconView?.frame = UIScreen.main.bounds
//        UIView.animate(withDuration: 0.3, animations: {
//            self.alpha = 0
//            self.tapIconView?.frame = self.originRect
//        }) { (finish) in
//            self.removeFromSuperview()
//        }
    }
    
    @discardableResult
    public func dismiss(block: CallBackPageBlock? = nil) -> Self {
        self.callBackLastPage = block
        return self
    }
}

// MARK: - delegate or data source
extension ImageBrower: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.albumCollect {
            self.currentPage = Int(ceil(scrollView.contentOffset.x / UIScreen.main.bounds.size.width))
            //print("scrollViewDidScroll:\(self.currentPage)")
            self.indexLabel.text = String(format: "%02d/%02d", max(0, min(self.imageModels.count, self.currentPage + 1)), self.imageModels.count)
        }
    }
}

extension ImageBrower: UICollectionViewDataSource, UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageModels.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = imageModels[indexPath.row]
        if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ImageBrowerItem.self), for: indexPath) as? ImageBrowerItem {
            itemCell.contentView.backgroundColor = .black
            itemCell.model = model
            itemCell.showMinZoomScale = showMinZoomScale
            itemCell.showMaxZoomScale = showMaxZoomScale
            return itemCell
        }
        return UICollectionViewCell()
    }
}

// MARK: - ImageBrowerItem
open class ImageBrowerItem: UICollectionViewCell {

    var model: ImageBrowerModel? {
        didSet {
            if model?.mode == ImageBrower.Mode.imagePath {
                // iconView.kf.indicatorType = .activity
                iconView.kf.setImage(with: URL(string: model?.path ?? ""), placeholder: nil, options: [.transition(.fade(1))]) { _, _ in
                    if self.activityView.isAnimating == false {
                        self.activityView.startAnimating()
                    }
                } completionHandler: { _ in
                    self.activityView.stopAnimating()
                }
            } else {
                iconView.image = model?.image
            }
        }
    }

    let subScroll = UIScrollView()
    let activityView = UIActivityIndicatorView(style: .large)
    let iconView = UIImageView()

    /// 缩放比例
    var showMinZoomScale: CGFloat = 1 {
        didSet {
            subScroll.minimumZoomScale = showMinZoomScale
        }
    }
    var showMaxZoomScale: CGFloat = 3 {
        didSet {
            subScroll.maximumZoomScale = showMaxZoomScale
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.addSubview(subScroll)
        self.contentView.addSubview(activityView)
        subScroll.addSubview(iconView)

        subScroll.frame = self.bounds
        subScroll.minimumZoomScale = 1
        subScroll.maximumZoomScale = 3
        subScroll.delegate = self

        activityView.center = subScroll.center

        iconView.frame = UIScreen.main.bounds
        iconView.contentMode = .scaleAspectFit
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageBrowerItem: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
         guard scrollView == self.subScroll else {
             return nil
         }
         return scrollView.subviews.filter({ $0.isKind(of: UIImageView.self) }).first
     }
}

// MARK: - ImageBrowerModel
public struct ImageBrowerModel {

    var mode: ImageBrower.Mode?
    var image: UIImage?
    var path: String?

    init(mode: ImageBrower.Mode = .imageObject, image: UIImage? = nil, path: String? = nil) {
        self.mode = mode
        self.image = image
        self.path = path
    }
}
