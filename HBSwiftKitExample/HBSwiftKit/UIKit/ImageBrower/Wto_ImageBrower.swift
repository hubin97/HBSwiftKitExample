//
//  Wto_ImageBrower.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/8/21.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation
import Kingfisher

//MARK: - global var and methods
fileprivate let defOriginRect = CGRect(x: UIScreen.main.bounds.size.width/2 - 0.5, y: UIScreen.main.bounds.size.height/2 - 0.5, width: 1, height: 1)
fileprivate let lineSpacing: CGFloat = 0 // 间隙

extension Wto_ImageBrower {
    
    enum Mode {
         case imageObject  // UIImage
         case imagePath    // URL
     }
}

//MARK: - main class
class Wto_ImageBrower: UIView {
    
    var loadMode: Wto_ImageBrower.Mode = .imageObject
    var imageModels = [Wto_ImageBrowerModel]()

    var originRect = CGRect()
//    var tapIconView: UIImageView?
    var tapGes: UITapGestureRecognizer!
    var currentPage = 0  // 当前页下标
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        //layout.sectionInset = UIEdgeInsets(top: albumMinSpacing, left: 2 * albumMinSpacing, bottom: albumMinSpacing, right: 2 * albumMinSpacing)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return layout
    }()
    
    lazy var albumCollect: UICollectionView = {
        let collection = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: layout)
        collection.register(Wto_ImageBrowerItem.self, forCellWithReuseIdentifier: NSStringFromClass(Wto_ImageBrowerItem.self))
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .black
        collection.isPagingEnabled = true
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        
        addSubview(albumCollect)
        
        tapGes = UITapGestureRecognizer.init(target: self, action: #selector(hide))
        albumCollect.addGestureRecognizer(tapGes)
        
        //ImageCache.default.clearMemoryCache()
        /// 设置内存可缓存容量 设定值为 像素数 设定为1, 强制写入磁盘
        // 有闪退问题 data (CacheSerializer.swift:0)
        //ImageCache.default.maxMemoryCost = 1024 * 1024 * 10
    }
    
    convenience init(loadMode: Wto_ImageBrower.Mode, dataSource: Array<Any>, tapIndex: Int = 0, originRect: CGRect = defOriginRect) {
        self.init(frame: UIScreen.main.bounds)
        
        self.loadMode = loadMode
        self.originRect = originRect
        self.currentPage = tapIndex

        if loadMode == .imageObject {
            for data in dataSource {
                if let image = data as? UIImage {
                    self.imageModels.append(Wto_ImageBrowerModel.init(mode: .imageObject, image: image))
                }
            }
        } else if loadMode == .imagePath {
            for data in dataSource {
                if let path = data as? String {
                    self.imageModels.append(Wto_ImageBrowerModel.init(mode: .imagePath, path: path))
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - private mothods
extension Wto_ImageBrower {
    
    /// 移除点击hide手势
    func removeTapHideGes() {
        self.albumCollect.removeGestureRecognizer(tapGes)
    }
}

//MARK: - call backs
extension Wto_ImageBrower {
    
    @objc func show() {
        
        self.albumCollect.reloadData()
        // TODO: 这个地方的方向待确认
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
    
    @objc func hide() {
  
        self.removeFromSuperview()
        
//        self.alpha = 1
//        self.tapIconView?.frame = UIScreen.main.bounds
//        UIView.animate(withDuration: 0.3, animations: {
//            self.alpha = 0
//            self.tapIconView?.frame = self.originRect
//        }) { (finish) in
//            self.removeFromSuperview()
//        }
    }
}

//MARK: - delegate or data source
extension Wto_ImageBrower: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.albumCollect {
            self.currentPage = Int(ceil(scrollView.contentOffset.x / UIScreen.main.bounds.size.width))
            //print("scrollViewDidScroll:\(self.currentPage)")
        }
    }
}

extension Wto_ImageBrower: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = imageModels[indexPath.row]
        let itemCell: Wto_ImageBrowerItem = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(Wto_ImageBrowerItem.self), for: indexPath) as! Wto_ImageBrowerItem
        itemCell.contentView.backgroundColor = .black
        itemCell.model = model
        return itemCell
    }
}

//MARK: - other classes
class Wto_ImageBrowerItem: UICollectionViewCell {
    
    var model: Wto_ImageBrowerModel? {
        didSet {
            
            if model?.mode == Wto_ImageBrower.Mode.imagePath {
                //iconView.kf.indicatorType = .activity
                iconView.kf.setImage(with: URL(string: model?.path ?? ""), placeholder: nil, options: [.transition(.fade(1))], progressBlock: { (receivedSize, totalSize) in
                    if self.activityView.isAnimating == false {
                        self.activityView.startAnimating()
                    }
                }) { (image, error, type, imageUrl) in
                    self.activityView.stopAnimating()
                }
            } else {
                iconView.image = model?.image
            }
        }
    }
    
    let subScroll = UIScrollView()
    let activityView = UIActivityIndicatorView.init(style: .whiteLarge)
    let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(subScroll)
        self.addSubview(activityView)
        subScroll.addSubview(iconView)

        subScroll.frame = self.bounds
        subScroll.minimumZoomScale = 1
        subScroll.maximumZoomScale = 3
        subScroll.delegate = self
        
        activityView.center = subScroll.center

        iconView.frame = UIScreen.main.bounds
        iconView.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Wto_ImageBrowerItem: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
         guard scrollView == self.subScroll else {
             return nil
         }
         
         return scrollView.subviews.filter( { $0.isKind(of: UIImageView.self) } ).first
     }
}

///
class Wto_ImageBrowerModel {
    
    var mode: Wto_ImageBrower.Mode?
    var image: UIImage?
    var path: String?
    
    init() {
    }
    
    convenience init(mode: Wto_ImageBrower.Mode = .imageObject, image: UIImage? = nil, path: String? = nil) {
        self.init()
        
        self.mode = mode
        self.image = image
        self.path = path
    }
}
