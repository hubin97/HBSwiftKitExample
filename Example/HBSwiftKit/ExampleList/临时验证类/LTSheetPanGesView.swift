//
//  LTSheetPanGesView.swift
//  Momcozy
//
//  Created by hubin.h on 2024/7/1.
//  Copyright © 2020 路特创新. All rights reserved.

/**
 ```
 使用示例:
 let alert = LTSheetPanGesView(containerH: kScreenH - kNavBarAndSafeHeight)
 alert.show()
 DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
     alert.containerH = kScreenW + kBottomSafeHeight
     alert.updateLayout()
     alert.show()
 }
 ```
 */
import UIKit

public protocol LTSheetOptionViewDelegate: AnyObject {
    func show(view: LTSheetPanGesView)
    func hide(view: LTSheetPanGesView)
}

public class LTSheetPanGesView: UIView {
    
    weak var sheetOptionViewDelegate: LTSheetOptionViewDelegate?
    // 容器高度 containerH
    public var containerH: CGFloat = 0
    
    /// 是否开启蒙层点击
    var isMaskEnable: Bool = false
    public lazy var maskingView: UIView = {
        let _maskingView = UIView(frame: UIScreen.main.bounds)
        _maskingView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        _maskingView.isUserInteractionEnabled = true
        _maskingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(_:))))
        //_maskingView.isHidden = true
        return _maskingView
    }()
    
    private var startY: CGFloat = 0
    private var isPanAvilable: Bool = false
    private override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        kAppKeyWindow?.addSubview(maskingView)
    }
    
    public convenience init(containerH: CGFloat? = nil) {
        self.init()
        self.containerH = containerH ?? kScreenW + kBottomSafeHeight
        self.frame = CGRect(x: 0, y: kScreenH, width: kScreenW, height: self.containerH)
        self.setRectCorner(rectCorner: [.topLeft, .topRight], radiiSize: 10)

        kAppKeyWindow?.addSubview(self)
        kAppKeyWindow?.bringSubviewToFront(self)
        self.backgroundColor = .white
        self.setupLayout()
    }
    
    @objc private func tapAction(_ tap: UITapGestureRecognizer) {
        if !self.isPanAvilable && self.isMaskEnable {
            self.hide()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setupLayout() {}
}

extension LTSheetPanGesView {
    
    public func show() {
        UIView.animate(withDuration: 0.3) {
            self.minY = kScreenH - self.containerH
        } completion: { (_) in
            //self.maskingView.isHidden = false
            self.sheetOptionViewDelegate?.show(view: self)
        }
    }
    
    public func hide() {
        self.maskingView.isHidden = true
        let scale = (kScreenH - self.minY)/self.containerH
        UIView.animate(withDuration: 0.3 * Double(scale)) {
            self.minY = kScreenH
        } completion: { (_) in
            self.sheetOptionViewDelegate?.hide(view: self)
        }
    }
    
    /// 更新容器布局
    public func updateLayout() {
        self.frame = CGRect(x: 0, y: kScreenH, width: kScreenW, height: self.containerH)
        self.setRectCorner(rectCorner: [.topLeft, .topRight], radiiSize: 10)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

extension LTSheetPanGesView {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        if ceil(Double(self.minY)) >= ceil(Double((kScreenH - self.containerH))) {
            isPanAvilable = true
            startY = point.y
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        if isPanAvilable && ceil(Double(self.minY)) >= ceil(Double((kScreenH - self.containerH))) {
            let newY = point.y
            let dy = newY - startY
            self.minY = max(self.minY + dy, CGFloat(ceil(Double((kScreenH - self.containerH)))))
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        if isPanAvilable {
            let newY = point.y
            let dy = newY - startY
            if dy > 0 {
                self.hide()
            } else {
                if self.minY > (kScreenH - 2 * containerH/3) {
                    self.hide()
                } else {
                    self.show()
                }
            }
            isPanAvilable = false
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        if isPanAvilable {
            let newY = point.y
            let dy = newY - startY
            if dy > 0 {
                self.hide()
            } else {
                if self.minY > (kScreenH - 2 * containerH/3) {
                    self.hide()
                } else {
                    self.show()
                }
            }
            isPanAvilable = false
        }
    }
}
