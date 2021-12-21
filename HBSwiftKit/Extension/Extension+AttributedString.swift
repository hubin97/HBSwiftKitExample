//
//  Extension+AttributedString.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/12/21.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit

// MARK: - global var and methods
typealias Extension_AttributedString = NSMutableAttributedString

// MARK: -
extension Extension_AttributedString {

    /// 获取范围
    var allRange: NSRange {
        return NSMakeRange(0, length)
    }

    /// 富文本拼接
    /// - Parameter attrString: 要拼接的富文本
    /// - Returns: attributes
    @discardableResult
    public func addAttrs(_ attrString: NSMutableAttributedString) -> NSMutableAttributedString {
        self.append(attrString)
        return self
    }

    /// 设置字体大小
    /// - Parameters:
    ///   - font: font
    ///   - range: range 默认NSMakeRange(0, length)
    /// - Returns: attributes
    @discardableResult
    public func addAttr_font(_ font: UIFont, range: NSRange? = nil) -> NSMutableAttributedString {
        self.addAttributes([NSAttributedString.Key.font: font], range: range ?? allRange)
        return self
    }

    /// 设置字体前景色
    /// - Parameters:
    ///   - color: color
    ///   - range: range 默认NSMakeRange(0, length)
    /// - Returns: attributes
    @discardableResult
    public func addAttr_fColor(_ color: UIColor, range: NSRange? = nil) -> NSMutableAttributedString {
        self.addAttributes([NSAttributedString.Key.foregroundColor: color], range: range ?? allRange)
        return self
    }

    /// 设置字体的背景色
    /// - Parameters:
    ///   - color: color
    ///   - range: range 默认NSMakeRange(0, length)
    /// - Returns: attributes
    @discardableResult
    public func addAttr_bColor(_ color: UIColor, range: NSRange? = nil) -> NSMutableAttributedString {
        self.addAttributes([NSAttributedString.Key.backgroundColor: color], range: range ?? allRange)
        return self
    }

    /// 添加删除线
    /// - Parameters:
    ///   - lineWidth: 线宽
    ///   - color: 颜色
    ///   - range: range 默认NSMakeRange(0, length)
    /// - Returns: attributes
    @discardableResult
    public func addAttr_midline(lineWidth: Int, color: UIColor, range: NSRange? = nil) -> NSMutableAttributedString {
        self.addAttributes([.strikethroughStyle: lineWidth, .strikethroughColor: color], range: range ?? allRange)
        return self
    }

    /// 添加下划线
    /// 测试验证 single, double是支持的, 其他的不显示(有什么设置被忽略了???)
    /// - Parameters:
    ///   - style: 样式
    ///   - color: 颜色
    ///   - range: range 默认NSMakeRange(0, length)
    /// - Returns: attributes
    @discardableResult
    public func addAttr_underline(style: NSUnderlineStyle, color: UIColor, range: NSRange? = nil) -> NSMutableAttributedString {
        self.addAttributes([.underlineStyle: style.rawValue, .underlineColor: color], range: range ?? allRange)
        return self
    }

    /// 添加文字描边 (虚体字)
    /// - Parameters:
    ///   - width: width
    ///   - color: color
    ///   - range: range 默认NSMakeRange(0, length)
    /// - Returns: attributes
    @discardableResult
    public func addAttr_stroke(width: CGFloat, color: UIColor, range: NSRange? = nil) -> NSMutableAttributedString {
        self.addAttributes([.strokeWidth: width, .strokeColor:color], range: range ?? allRange)
        return self
    }

    /// 添加字间距
    /// - Parameters:
    ///   - kern: 字间距
    ///   - range: range 默认NSMakeRange(0, length)
    /// - Returns: attributes
    @discardableResult
    public func addAttr_kern(_ kern: CGFloat, range: NSRange? = nil) -> NSMutableAttributedString {
        self.addAttributes([.kern: kern], range: range ?? allRange)
        return self
    }

    /// 添加行间距
    /// 注意: 如果忽略font, 此方法添加的行间距会不准确, 请参考 Extension+Label的setLabelLineSpacing方法
    /// - Parameters:
    ///   - lineSpacing: 行间距
    ///   - referFont: 段落文本字体参考大小
    ///   - lineBreakMode: 换行方式
    ///   - textAlignment: 对齐方式
    ///   - range: range 默认NSMakeRange(0, length)
    /// - Returns: attributes
    @discardableResult
    public func addAttr_lineSpacing(_ lineSpacing: CGFloat, referFont: UIFont? = nil, lineBreakMode: NSLineBreakMode = .byWordWrapping, textAlignment: NSTextAlignment = .left, range: NSRange? = nil) -> NSMutableAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = lineBreakMode
        style.alignment = textAlignment
        if let font = referFont {
            style.lineSpacing = lineSpacing - (font.lineHeight - font.pointSize)
        } else {
            style.lineSpacing = lineSpacing
        }
        self.addAttribute(.paragraphStyle, value: style, range: range ?? allRange)
        return self
    }

    /// 添加阴影
    /// // 测试验证不支持局部阴影, 且阴影内容包括 前/后背景色, 删除线, 描边字(下划线排除)
    /// - Parameters:
    ///   - shadowOffset: 相对位置
    ///   - color: 颜色
    /// - Returns: attributes
    @discardableResult
    public func addAttr_shadow(shadowOffset: CGSize? = nil, color: UIColor? = nil) -> NSMutableAttributedString {
        let shadow = NSShadow()
        shadow.shadowColor = color ?? .black
        shadow.shadowOffset = shadowOffset ?? CGSize(width: 3, height: 3)
        self.addAttributes([NSAttributedString.Key.shadow: shadow], range: allRange)
        return self
    }

    /// 添加链接🔗
    /// 1.注意系统Label中并不提供获取文段中URL的方法; 但是TextView可以通过代理方法获取点击到URL,
    ///  UITextViewDelegate.textView(_:shouldInteractWith:in:interaction:).
    /// 2.注意url必须带上'https://'或者'http://', 否则无效
    /// - Parameters:
    ///   - url: 链接地址
    ///   - range: range 默认NSMakeRange(0, length)
    /// - Returns: attributes
    @discardableResult
    public func addAttr_link(url: URL, range: NSRange? = nil) -> NSMutableAttributedString {
        self.addAttributes([NSAttributedString.Key.link: url], range: range ?? allRange)
        return self
    }

    /// 文字效果
    /// - Parameters:
    ///   - textEffect: 目前仅支持 .letterpressStyle: 凸版印刷样式
    ///   - range: range 默认NSMakeRange(0, length)
    /// - Returns: attributes
    @discardableResult
    public func addAttr_textEffect(textEffect: NSAttributedString.TextEffectStyle, range: NSRange? = nil) -> NSMutableAttributedString {
        self.addAttributes([NSAttributedString.Key.textEffect: textEffect.rawValue], range: range ?? allRange)
        return self
    }
}
