//
//  Extension+Button.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/4/22.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import CoreGraphics

//单元测试 ✅
//MARK: - global var and methods
fileprivate typealias Extension_Button = UIButton

private var touchAreaInsetsKey: Void?
private var showScaleAnimateKey: Void?
private var showScaleKey: Void?
private var drawTextLineColorKey: Void?
private var drawTextLineWidthKey: Void?

//MARK: - main class

//MARK: - private mothods
extension Extension_Button {
    
    /// 扩展按钮可点击范围
    public var touchAreaInsets: UIEdgeInsets? {
        get {
            objc_getAssociatedObject(self, &touchAreaInsetsKey) as? UIEdgeInsets
        }
        set {
            objc_setAssociatedObject(self, &touchAreaInsetsKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 展示触摸宽高拉伸效果
    public var showScaleAnimate: Bool? {
        get {
            objc_getAssociatedObject(self, &showScaleAnimateKey) as? Bool
        }
        set {
            objc_setAssociatedObject(self, &showScaleAnimateKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    /// 注意:必须同showScaleAnimate属性联用, 表示缩放比例, 默认1.2
    public var showScale: CGFloat? {
        get {
            objc_getAssociatedObject(self, &showScaleKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &showScaleKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 绘制文本下划线 颜色, 默认黑色
    public var drawTextLineColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &drawTextLineColorKey) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &drawTextLineColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.setNeedsDisplay()
        }
    }
    /// 绘制文本下划线 线宽, 默认1
    public var drawTextLineWidth: CGFloat? {
        get {
            objc_getAssociatedObject(self, &drawTextLineWidthKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &drawTextLineWidthKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

//MARK: - override methods
extension Extension_Button {
 
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let touchAreaInsets = self.touchAreaInsets else {
            return super.point(inside: point, with: event)
        }
        var bounds = self.bounds
        bounds = CGRect(x: bounds.origin.x - touchAreaInsets.left,
                        y: bounds.origin.y - touchAreaInsets.top,
                        width: bounds.size.width + touchAreaInsets.left + touchAreaInsets.right,
                        height: bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom)
        return bounds.contains(point)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        add3dScaleAnimate()
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        add3dScaleAnimate()
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        remove3dScaleAnimate()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        remove3dScaleAnimate()
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if drawTextLineColor != nil || drawTextLineWidth != nil {
            // self.titleLabel?.font.descender绘制的是相对font的基线, 相对底部划线略高些
            guard let textRect = self.titleLabel?.frame/*, let descender = self.titleLabel?.font.descender*/ else { return }
            guard let contextRef = UIGraphicsGetCurrentContext() else { return }
            let y = textRect.origin.y + textRect.size.height - (drawTextLineWidth ?? 1) //textRect.origin.y + textRect.size.height + descender + 1
            contextRef.setStrokeColor((drawTextLineColor ?? .black).cgColor)
            contextRef.move(to: CGPoint(x: textRect.origin.x, y: y))
            contextRef.addLine(to: CGPoint(x: textRect.origin.x + textRect.size.width, y: y))
            contextRef.setLineWidth(drawTextLineWidth ?? 1)
            contextRef.drawPath(using: CGPathDrawingMode.stroke)
            contextRef.closePath()
        }
    }
}

//MARK: - private methods
extension Extension_Button {
    
    private func add3dScaleAnimate() {
        guard let show3DScaleAnimate = showScaleAnimate, show3DScaleAnimate == true else { return }
        UIView.animate(withDuration: 0.2) {
            let scale = self.showScale ?? 1.2
            self.layer.transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        }
    }
    
    private func remove3dScaleAnimate() {
        guard let show3DScaleAnimate = showScaleAnimate, show3DScaleAnimate == true else { return }
        UIView.animate(withDuration: 0.2) {
            self.layer.transform = CATransform3DIdentity
        }
    }
}

//MARK: - other classes
