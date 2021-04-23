//
//  Extension+Label.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/1/20.
//  Copyright © 2020 Wingto. All rights reserved.

//单元测试 ✅
import Foundation

//MARK: - global var and methods
fileprivate typealias Extension_Label = UILabel

//MARK: - main class
extension Extension_Label {

    /// 标签快捷初始化
    /// - Parameters:
    ///   - text: 文字
    ///   - textColor: 文字颜色
    ///   - textFont: 文字大小
    ///   - textAlignment: 文字对齐方式
    ///   - lineBreakMode: 文字换行方式
    ///   - numberLines: 文字占用行数
    ///   - lineSpacing: 文字行间距
    public convenience init(text: String?, textColor: UIColor = .black, textFont: UIFont = UIFont.systemFont(ofSize: 17.0), textAlignment: NSTextAlignment = .left, lineBreakMode: NSLineBreakMode = .byWordWrapping, numberLines: Int = 1, lineSpacing: CGFloat? = nil) {
        self.init()
        self.textColor = textColor
        self.font = textFont
        self.numberOfLines = numberLines
        self.clipsToBounds = false
        if lineSpacing != nil {
            self.attributedText = NSAttributedString(string: text ?? "", attributes: setLabelLineSpacing(lineSpacing: lineSpacing ?? 7, lineBreakMode: lineBreakMode, textAlignment: textAlignment))
        } else {
            self.text = text
            self.textAlignment = textAlignment
            self.lineBreakMode = lineBreakMode
        }
    }

    /// 设置标签行间距 默认 7
    /// - Parameters:
    ///   - lineSpacing: 行间距
    ///   - lineBreakMode: 文字换行方式
    ///   - textAlignment: 文字对齐方式
    /// - Returns: 富文本段属性字典
    public func setLabelLineSpacing(lineSpacing: CGFloat = 7, lineBreakMode: NSLineBreakMode = .byWordWrapping, textAlignment: NSTextAlignment = .left) -> [NSAttributedString.Key : Any]? {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing - (self.font.lineHeight - self.font.pointSize)
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = lineBreakMode
        let attributes = [NSAttributedString.Key.font: self.font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        return attributes as [NSAttributedString.Key : Any]
    }

    /// 预计算高度
    /// - Parameters:
    ///   - maxWidth: 指定最大宽度
    ///   - maxLine: 行数,默认0
    /// - Returns: 预算高度
    public func estimatedHeight(maxWidth: CGFloat, maxLine: Int = 0) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.backgroundColor = backgroundColor
        label.lineBreakMode = lineBreakMode
        label.font = font
        label.text = text
        label.textAlignment = textAlignment
        label.numberOfLines = maxLine
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
    
    /// 预计算宽度
    /// - Parameters:
    ///   - maxHeight: 指定最大高度
    ///   - maxLine: 行数,默认0
    /// - Returns: 预算宽度
    public func estimatedWidth(maxHeight: CGFloat, maxLine:Int = 0) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: maxHeight))
        label.numberOfLines = 0
        label.backgroundColor = backgroundColor
        label.lineBreakMode = lineBreakMode
        label.font = font
        label.text = text
        label.textAlignment = textAlignment
        label.numberOfLines = maxLine
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.width
    }

}
