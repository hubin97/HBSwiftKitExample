//
//  YTTabBar.swift
//  YTTabBar
//
//  Created by Hubin_Huang on 2021/5/10.
//  Copyright © 2020 Wingto. All rights reserved.

import UIKit
import Foundation

//MARK: - global var and methods

//MARK: - main class
open class YTTabBar: UIView {
    
    var tapAction: ((_ idx: Int, _ item: YTTabBarItem) -> ())?
    var selectedIdx = 0
    var canDuplicateTap = false
    /// 设定目标frame
    var targetFrame: CGRect?
    var tabBarItems: [YTTabBarItem]?
    var textNormalColor = UIColor.gray
    var textSelectColor = UIColor.systemBlue
    var textFont = UIFont.systemFont(ofSize: 10, weight: .medium)
    var borderColor: UIColor?
    
    /// YTTabBar便捷初始化
    /// - Parameters:
    ///   - frame: 不传, 默认系统位置
    ///   - tabBarItems: tabBarItems数据源
    ///   - textNormalColor: 正常色
    ///   - textSelectColor: 选中色
    ///   - textFont: 标题字号
    ///   - borderColor: 上边框色, 默认 groupTableViewBackground
    ///   - selectedIdx: 默认选中下标
    ///   - canDuplicateTap: 是否可重复点击, 默认同TabBar(不可重复); 但工具栏的应该是需要重复点击的
    ///   - tapAction: 事件回调
    public convenience init(frame: CGRect = CGRect.zero, tabBarItems: [YTTabBarItem], textNormalColor: UIColor = UIColor.gray, textSelectColor: UIColor = UIColor.systemBlue, textFont: UIFont = UIFont.systemFont(ofSize: 10, weight: .medium), borderColor: UIColor? = UIColor.groupTableViewBackground, selectedIdx: Int = 0, canDuplicateTap: Bool = false, tapAction: ((_ idx: Int, _ item: YTTabBarItem) -> ())? = nil) {
        self.init(frame: frame)
        self.targetFrame = self.frame
        self.tabBarItems = tabBarItems
        self.textNormalColor = textNormalColor
        self.textSelectColor = textSelectColor
        self.textFont = textFont
        self.borderColor = borderColor
        self.selectedIdx = selectedIdx
        self.canDuplicateTap = canDuplicateTap
        self.tapAction = tapAction
        setUp()
    }
    
    func setUp() {
        guard let items = tabBarItems, items.count > 0 else { return }
        self.subviews.forEach({ $0.removeFromSuperview() })
        if let bColor = borderColor {
            let lineView = UIView.init(frame: self.bounds)
            lineView.frame.size.height = 1
            addSubview(lineView)
            lineView.backgroundColor = bColor
        }
        let count = items.count
        let padding: CGFloat = 2
        let itemW: CGFloat = (self.bounds.size.width - (padding * 2) - (2 * padding) * CGFloat(count - 1)) / CGFloat(count)
        let itemH: CGFloat = 48 // 系统默认高度
        for idx in 0..<count {
            let item = items[idx]
            self.addSubview(item)
            item.frame = CGRect(x: 2 * padding + CGFloat(idx) * (itemW + padding), y: 1, width: itemW, height: itemH)
            item.setTitle(item.title, for: .normal)
            item.titleLabel?.font = textFont
            item.titleLabel?.textAlignment = .center
            item.setTitleColor(textNormalColor, for: .normal)
            item.setTitleColor(textSelectColor, for: .highlighted)
            item.setTitleColor(textSelectColor, for: .selected)
            item.setImage(UIImage(named: item.normal_image ?? "")?.withRenderingMode(.alwaysOriginal), for: .normal)
            item.setImage(UIImage(named: item.select_image ?? "")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
            item.setImage(UIImage(named: item.select_image ?? "")?.withRenderingMode(.alwaysOriginal), for: .selected)
            item.addTarget(self, action: #selector(itemAtion(_:)), for: .touchUpInside)
            item.adjustsImageWhenHighlighted = false  // 禁用按压高亮
            item.tag = 1000 + idx
            item.isSelected = idx == selectedIdx ? true: false
        }
    }
    
    public func updateLayout(duration: TimeInterval, isPortrait: Bool) {
        UIView.animate(withDuration: duration) {
            if isPortrait {
                self.frame = self.targetFrame ?? CGRect(x: 0, y: kScreenH - kTabBarAndSafeHeight, width: kScreenW, height: kTabBarAndSafeHeight)
            } else {
                //let orientation = UIDevice.current.orientation
                self.frame = CGRect(x: 0, y: kScreenW - kTabBarHeight, width: kScreenH, height: kTabBarHeight)
            }
        } completion: { (finish) in
            self.setUp()
        }
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        if frame == .zero {
            self.frame = CGRect(x: 0, y: kScreenH - kTabBarAndSafeHeight, width: kScreenW, height: kTabBarAndSafeHeight)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - private mothods
extension YTTabBar {
    
    public func addTabBarItem(_ item: YTTabBarItem) {
        tabBarItems?.append(item)
        setUp()
    }
    
    public func selectIdx(idx: Int) {
        selectIdx(idx: idx, true)
    }
    
    private func selectIdx(idx: Int, _ needActionBlock: Bool = false) {
        guard selectedIdx != idx else { return }
        tabBarItems?.forEach({ $0.isSelected = ($0.tag == (idx + 1000)) ? true: false })
        if needActionBlock { // 需要回调事件?
            guard let itemModel = tabBarItems?.filter({ $0.tag == (idx + 1000) }).first else { return }
            self.tapAction?(idx, itemModel)
        }
    }
}

//MARK: - call backs
extension YTTabBar {
    
    @objc func itemAtion(_ sender: YTTabBarItem) {
        guard let items = tabBarItems, self.canDuplicateTap || (!self.canDuplicateTap && sender.isSelected == false) else { return }
        items.forEach({ $0.isSelected = ($0.tag == sender.tag) ? true: false })
        self.selectedIdx = sender.tag - 1000
        self.tapAction?(selectedIdx, sender)
    }
    
    //MARK: show/hide
    public func show(_ animated: Bool = false) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(self)
            if animated {
                self.showAnimate()
            } else {
                self.frame = CGRect(x: 0, y: kScreenH - kTabBarAndSafeHeight, width: kScreenW, height: kTabBarAndSafeHeight)
            }
        }
    }
    
    /// 默认上拉动画
    open func showAnimate() {
        self.frame = CGRect(x: 0, y: kScreenH, width: kScreenW, height: kTabBarAndSafeHeight)
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: 0, y: kScreenH - kTabBarAndSafeHeight, width: kScreenW, height: kTabBarAndSafeHeight)
        }
    }
    
    public func hide(_ animated: Bool = false) {
        if animated {
            self.hideAnimate()
        } else {
            self.removeFromSuperview()
        }
    }
    
    open func hideAnimate() {
        self.frame = CGRect(x: 0, y: kScreenH - kTabBarAndSafeHeight, width: kScreenW, height: kTabBarAndSafeHeight)
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: 0, y: kScreenH, width: kScreenW, height: kTabBarAndSafeHeight)
        } completion: { (finish) in
            self.removeFromSuperview()
        }
    }
}

//MARK: - delegate or data source
extension YTTabBar {
    
}

//MARK: - other classes
public class YTTabBarItem: UIButton {
    
    public var title: String?
    public var normal_image: String?
    public var select_image: String?
    
    /// 图标限制高度
    private let limitHValue: CGFloat = 34.5

    /// YTTabBarItem模型初始化
    /// - Parameters:
    ///   - title: 标题
    ///   - normal_image: 正常图标, //30 * 30
    ///   - select_image: 选中图标, //30 * 30
    public convenience init(title: String?, normal_image: String?, select_image: String?) {
        self.init(type: .custom)
        self.title = title
        self.normal_image = normal_image
        self.select_image = select_image
    }
    
    public override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var imageRect = contentRect
        imageRect.size.width = estimatedIconSize().width
        imageRect.size.height = estimatedIconSize().height
        imageRect.origin.y = (limitHValue - imageRect.size.width)/2
        imageRect.origin.x = (contentRect.size.width - imageRect.size.width)/2
        return imageRect
    }
    
    public override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var titleRect = contentRect
        titleRect.origin.x = 5
        titleRect.origin.y = limitHValue
        titleRect.size.width = contentRect.size.width - 2 * titleRect.origin.x
        titleRect.size.height = contentRect.size.height - limitHValue - 3.5
        return titleRect
    }
    
    //MARK: 返回Icon估计宽高值, 且默认宽高30
    func estimatedIconSize() -> CGSize {
        if let src = normal_image, let img = UIImage(named: src),
           img.size.width > 0 && img.size.height > 0 {
            let lastH = min(limitHValue, img.size.height)
            let lastW = img.size.width / img.size.height * lastH
            return CGSize(width: lastW, height: lastH)
        }
        return CGSize(width: 30, height: 30)
    }
}
