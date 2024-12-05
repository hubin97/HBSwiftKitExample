//
//  LTMarker.swift
//  Momcozy
//
//  Created by hubin.h on 2024/9/14.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import DGCharts

open class LTMarker: MarkerImage {
    // Customizable properties
    @objc open var backgroundColor: UIColor
    @objc open var cornerRadius: CGFloat
    @objc open var arrowMargin: CGFloat
    @objc open var arrowSize: CGSize
    @objc open var font: UIFont
    @objc open var textColor: UIColor
    @objc open var insets: UIEdgeInsets
    @objc open var minimumSize = CGSize()
    
    // Internal properties
    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key: Any]()
    
    // Custom initializer
    @objc public init(
        backgroundColor: UIColor,
        cornerRadius: CGFloat = 5.0,
        arrowMargin: CGFloat = 20,  // 距离图表点的间距
        arrowSize: CGSize = CGSize(width: 10, height: 5),
        font: UIFont,
        textColor: UIColor,
        insets: UIEdgeInsets = UIEdgeInsets.zero
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.arrowMargin = arrowMargin
        self.arrowSize = arrowSize
        self.font = font
        self.textColor = textColor
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        super.init()
    }
    
    // Offset for drawing marker
    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        var offset = self.offset
        var size = self.size

        if size.width == 0.0 && image != nil {
            size.width = image!.size.width
        }
        if size.height == 0.0 && image != nil {
            size.height = image!.size.height
        }

        let width = size.width
        let height = size.height
        let padding: CGFloat = 8.0

        var origin = point
        origin.x -= width / 2
        origin.y -= height

        // 限制气泡在图表的边界内
        if origin.x + offset.x < 0.0 {
            offset.x = -origin.x + padding
        } else if let chart = chartView,
                  origin.x + width + offset.x > chart.bounds.size.width {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }

        if origin.y + offset.y < 0 {
            offset.y = height + padding
        } else if let chart = chartView,
                  origin.y + height + offset.y > chart.bounds.size.height {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }

        // Adjust vertical offset
        if offset.y > 0 {
            // 如果箭头在下方，增加箭头的垂直间距
            offset.y += arrowMargin
        } else {
            // 如果箭头在上方，增加箭头的垂直间距
            offset.y -= arrowMargin
        }
        
        return offset
    }
    
    open override func draw(context: CGContext, point: CGPoint) {
        // 如果 label 为空，则不进行绘制
        guard let label = label else { return }

        // 获取绘制偏移量
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size

        // 计算矩形的绘制区域
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height

        // 设置箭头尖角和目标点之间的间距, // 你可以根据需求调整arrowMargin
        let arrowPadding: CGFloat = arrowMargin/2

        // 根据箭头的方向调整箭头位置
        if offset.y > 0 {
            // 如果箭头在下方，向上移动
            rect.origin.y -= arrowPadding
        } else {
            // 如果箭头在上方，向下移动
            rect.origin.y += arrowPadding
        }
        
        // 保存当前图形状态
        context.saveGState()

        // 设置填充颜色
        context.setFillColor(backgroundColor.cgColor)

        // 使用 UIBezierPath 绘制带圆角的矩形路径
        let path = UIBezierPath()
        
        if offset.y > 0 {
            // 如果 offset.y > 0，表示箭头在下方
            
            // 1. 从左上角开始
            path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arrowSize.height + cornerRadius))
            
            // 2. 画到左下角，预留圆角的空间
            path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - cornerRadius))
            
            // 3. 画左下角的圆角
            path.addQuadCurve(to: CGPoint(x: rect.origin.x + cornerRadius, y: rect.origin.y + rect.size.height),
                              controlPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
            
            // 4. 画到右下角，预留圆角的空间
            path.addLine(to: CGPoint(x: rect.origin.x + rect.size.width - cornerRadius, y: rect.origin.y + rect.size.height))
            
            // 5. 画右下角的圆角
            path.addQuadCurve(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height - cornerRadius),
                              controlPoint: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
            
            // 6. 画到右上角，预留圆角的空间
            path.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + arrowSize.height + cornerRadius))
            
            // 7. 画右上角的圆角
            path.addQuadCurve(to: CGPoint(x: rect.origin.x + rect.size.width - cornerRadius, y: rect.origin.y + arrowSize.height),
                              controlPoint: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + arrowSize.height))
            
            // 8. 画到箭头左边
            path.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0, y: rect.origin.y + arrowSize.height))
            
            // 9. 画箭头
            path.addLine(to: CGPoint(x: point.x, y: point.y + arrowPadding))
            
            // 10. 画到箭头右边
            path.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0, y: rect.origin.y + arrowSize.height))
            
            // 11. 画到左上角，预留圆角的空间
            path.addLine(to: CGPoint(x: rect.origin.x + cornerRadius, y: rect.origin.y + arrowSize.height))
            
            // 12. 画左上角的圆角
            path.addQuadCurve(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arrowSize.height + cornerRadius),
                              controlPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + arrowSize.height))
            
        } else {
            // 如果 offset.y <= 0，表示箭头在上方
            
            // 1. 从左上角开始
            path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + cornerRadius))
            
            // 2. 画到左下角，预留圆角的空间
            path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - arrowSize.height - cornerRadius))
            
            // 3. 画左下角的圆角
            path.addQuadCurve(to: CGPoint(x: rect.origin.x + cornerRadius, y: rect.origin.y + rect.size.height - arrowSize.height),
                              controlPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - arrowSize.height))
            
            // 4. 画到箭头左边
            path.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
            
            // 5. 画箭头
            path.addLine(to: CGPoint(x: point.x, y: point.y - arrowPadding))
            
            // 6. 画到箭头右边
            path.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
            
            // 7. 画到右下角，预留圆角的空间
            path.addLine(to: CGPoint(x: rect.origin.x + rect.size.width - cornerRadius, y: rect.origin.y + rect.size.height - arrowSize.height))
            
            // 8. 画右下角的圆角
            path.addQuadCurve(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height - arrowSize.height - cornerRadius),
                              controlPoint: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height - arrowSize.height))
            
            // 9. 画到右上角，预留圆角的空间
            path.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + cornerRadius))
            
            // 10. 画右上角的圆角
            path.addQuadCurve(to: CGPoint(x: rect.origin.x + rect.size.width - cornerRadius, y: rect.origin.y),
                              controlPoint: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
            
            // 11. 画到左上角，预留圆角的空间
            path.addLine(to: CGPoint(x: rect.origin.x + cornerRadius, y: rect.origin.y))
            
            // 12. 画左上角的圆角
            path.addQuadCurve(to: CGPoint(x: rect.origin.x, y: rect.origin.y + cornerRadius),
                              controlPoint: CGPoint(x: rect.origin.x, y: rect.origin.y))
        }

        // 填充路径
        context.addPath(path.cgPath)
        context.fillPath()

        // 调整文本框的绘制区域
        if offset.y > 0 {
            // 如果箭头在上，文本框的 y 坐标需要向下偏移
            rect.origin.y += self.insets.top + arrowSize.height * 2
        } else {
            // 如果箭头在下，文本框的
            rect.origin.y += self.insets.top + arrowSize.height
        }

        // 减去文本框的内边距
        rect.size.height -= self.insets.top + self.insets.bottom

        // 将当前上下文推入栈中，以便之后绘制文本
        UIGraphicsPushContext(context)
        
        // 绘制文本
        label.draw(in: rect, withAttributes: _drawAttributes)
        
        // 将当前上下文弹出栈
        UIGraphicsPopContext()
        
        // 恢复图形状态
        context.restoreGState()
    }
}

extension LTMarker {
 
    // Set label text
    @objc open func setLabel(_ newLabel: String?) {
        label = newLabel
        
        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor
        
        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}
