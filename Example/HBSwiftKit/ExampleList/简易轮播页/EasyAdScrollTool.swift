//
//  EasyAdScrollTool.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/3/1.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class EasyAdScrollTool: UIView {

    /** 视图展示样式 */
    enum AdStyle {
        case Page  // 轮播图
        case Line  // 走马灯样式
    }

    /** 视图动画方式 */
    enum AnimateType {
        case Left_Right
        case Top_Bottom
    }

    var style = AdStyle.Page
    var anitype = AnimateType.Left_Right
    var datas = [EasyAdScrollModel]()
    // 默认间隔2秒
    var interval = 2 {
        didSet {
            scrollTimer?.schedule(deadline: .now(), repeating: .seconds(interval))
        }
    }
    // 循环 默认YES
    var infiniteLoop = true
    // 自动循环 默认YES
    var autoScroll = true
    var scrollTimer: DispatchSourceTimer?

    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.itemSize = self.bounds.size
        layout.sectionInset = UIEdgeInsets.zero
        layout.scrollDirection = (anitype == AnimateType.Left_Right) ? .horizontal: .vertical
        return layout
    }()

    lazy var flowCollection: UICollectionView = {
        let collection = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        collection.register(EasyAdScrollItem.self, forCellWithReuseIdentifier: NSStringFromClass(EasyAdScrollItem.self))
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()

    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    /// 快捷初始化
    /// - Parameters:
    ///   - frame: 位置
    ///   - style: 风格
    ///   - animateType: 动画样式
    ///   - interval: 滚动间隔
    ///   - infiniteLoop: 是否循环
    ///   - datas: 数据源
    convenience init(frame: CGRect, style: EasyAdScrollTool.AdStyle, animateType: EasyAdScrollTool.AnimateType = .Left_Right, interval: Int = 2, infiniteLoop: Bool = true, datas: [EasyAdScrollModel]) {
        self.init(frame: frame)
        self.interval = interval
        self.infiniteLoop = infiniteLoop
        self.datas = datas
        addSubview(flowCollection)
        setUpTimer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        invalidateTimer()
    }
}

// MARK: - private mothods
extension EasyAdScrollTool {

    func setUpTimer() {
        if scrollTimer == nil {
            scrollTimer = DispatchSource.makeTimerSource(flags: [], queue: .global())
            scrollTimer?.schedule(deadline: .now(), repeating: .seconds(interval))
        }
        scrollTimer?.setEventHandler(handler: {[weak self] in
            DispatchQueue.main.async {
                self?.automaticScroll()
            }
        })
        scrollTimer?.resume()
    }

    func invalidateTimer() {
        scrollTimer?.cancel()
        scrollTimer = nil
    }

    func scrollToIndex(with index: Int) {
        guard !datas.isEmpty && index < datas.count else {
            flowCollection.scrollToItem(at: IndexPath(item: 0, section: 0), at: [], animated: false)
            return
        }
        flowCollection.scrollToItem(at: IndexPath(item: index, section: 0), at: [], animated: true)
    }

    func getCurrentIndex() -> Int {
        guard flowCollection.bounds.size.width > 0 && flowCollection.bounds.size.height > 0 else {
            return 0
        }

        var index = 0
        if anitype == AnimateType.Left_Right {
            index = Int((flowCollection.contentOffset.x + layout.itemSize.width * 0.5) / layout.itemSize.width)
        } else {
            index = Int((flowCollection.contentOffset.y + layout.itemSize.height * 0.5) / layout.itemSize.height)
        }
        return max(0, index)
    }

    func automaticScroll() {
        guard !datas.isEmpty else { return }
        let targetIndex = getCurrentIndex() + 1
        scrollToIndex(with: targetIndex)
    }
}

// MARK: - call backs
extension EasyAdScrollTool {

}

// MARK: - delegate or data source
extension EasyAdScrollTool: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = datas[indexPath.item]
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(EasyAdScrollItem.self), for: indexPath) as! EasyAdScrollItem
        item.model = model
        return item
    }
}

extension EasyAdScrollTool: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if autoScroll {
            invalidateTimer()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if autoScroll {
            setUpTimer()
        }
    }
}

// MARK: - other classes
struct EasyAdScrollModel {
    /** 左图 flag url or filename*/
    var iconName: String?
    /** 右图 flag url or filename*/
    var flagName: String?
    /** 右文 title */
    var title: String?
}

//
class EasyAdScrollItem: UICollectionViewCell {

    var model: EasyAdScrollModel? {
        didSet {
            iconView.image = UIImage(named: model?.iconName ?? "ib_share")
            flagView.image = UIImage(named: model?.flagName ?? "next_month_normal")
            titleLabel.text = model?.title
        }
    }

    var iconView = UIImageView()
    var flagView = UIImageView()
    var titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconView)
        addSubview(flagView)
        addSubview(titleLabel)

        let kpadding: CGFloat = 10.0
        // left icon
        var iconFrame: CGRect = frame
        iconFrame.origin.x = kpadding
        iconFrame.origin.y = kpadding
        iconFrame.size.height -= 2 * kpadding
        iconFrame.size.width = iconFrame.size.height
        iconView.frame = iconFrame

        // right icon
        var flagFrame: CGRect = frame
        flagFrame.size.height = 20.0
        flagFrame.size.width = flagFrame.size.height
        flagFrame.origin.x = frame.size.width - kpadding - flagFrame.size.width
        flagFrame.origin.y = (frame.size.height - flagFrame.size.height)/2
        flagView.frame = flagFrame

        // right title
        var titleFrame: CGRect = frame
        titleFrame.origin.x = kpadding*2 + iconFrame.size.height
        titleFrame.origin.y = kpadding
        titleFrame.size.width -= (titleFrame.origin.x + kpadding + flagFrame.size.width + kpadding)
        titleFrame.size.height -= kpadding * 2
        titleLabel.frame = titleFrame

        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
