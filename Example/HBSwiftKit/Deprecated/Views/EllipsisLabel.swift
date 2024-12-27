//
//  EllipsisLabel.swift
//  Momcozy
//
//  Created by hubin.h on 2024/12/18.

import Foundation

// MARK: - global var and methods

/// 省略号文本标签
class EllipsisLabel: UILabel {
    
    // 完整的文本
    var fullText: String = "" {
        didSet {
            updateText()
        }
    }
    
    // 最大显示行数
    var maxLines: Int = 2 {
        didSet {
            updateText()
        }
    }
    
    // 自定义省略部分的文本（默认是 "More"）
    var moreText: String = "More" {
        didSet {
            updateText()
        }
    }
    
    // "More" 按钮的富文本属性
    var moreAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 14),
        .foregroundColor: UIColor.blue,
        .underlineStyle: NSUnderlineStyle.single.rawValue // 默认带下划线
    ] {
        didSet {
            updateText()
        }
    }
    
    var textFont: UIFont {
        return self.font ?? UIFont.systemFont(ofSize: 14)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.numberOfLines = maxLines
        self.lineBreakMode = .byTruncatingTail
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.numberOfLines = maxLines
        self.lineBreakMode = .byTruncatingTail
    }
    
    func updateText() {
        guard maxLines > 0 else { return }
        
        // 计算最大文本宽度，限制为两行的高度
        let size = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = (fullText as NSString).boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: textFont],
            context: nil
        )
        
        let lineHeight = self.font.lineHeight
        let maxHeight = lineHeight * CGFloat(maxLines)
        
        if boundingRect.height > maxHeight {
            // 文本超过最大高度，需要截断
            let truncatedText = truncateText(fullText: fullText, maxWidth: self.bounds.width, maxHeight: maxHeight)
            self.attributedText = truncatedText
        } else {
            // 文本没有超出，正常显示
            self.text = fullText
        }
    }
    
    // 截取文本并加上 "..." 和 "More"
    private func truncateText(fullText: String, maxWidth: CGFloat, maxHeight: CGFloat) -> NSAttributedString {
        let ellipsis = "..."
        
        // 获取省略号和 "More" 文本的实际宽度
        let moreTextWidth = (moreText as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.bounds.height),
            options: .usesLineFragmentOrigin,
            attributes: moreAttributes,
            context: nil
        ).width
        
        let ellipsisWidth = (ellipsis as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.bounds.height),
            options: .usesLineFragmentOrigin,
            attributes: [.font: textFont],
            context: nil
        ).width
        
        // 计算最大可用宽度
        let availableWidth = maxWidth - moreTextWidth - ellipsisWidth
        
        // 获取截取后的文本
        let truncatedText = getTruncatedText(fullText: fullText, maxWidth: availableWidth, maxHeight: maxHeight)
        
        let finalText = "\(truncatedText)\(ellipsis)\(moreText)"
        
        let attributedText = NSMutableAttributedString(string: finalText)
        
        // 为不同部分添加不同的样式
        let truncatedTextRange = NSRange(location: 0, length: truncatedText.count)
        let ellipsisRange = NSRange(location: truncatedText.count, length: ellipsis.count)
        let moreRange = NSRange(location: truncatedText.count + ellipsis.count, length: moreText.count)
        
        // 设置富文本样式
        attributedText.addAttributes([.font: textFont], range: truncatedTextRange)
        attributedText.addAttributes([.foregroundColor: UIColor.gray], range: ellipsisRange)
        attributedText.addAttributes(moreAttributes, range: moreRange)
        
        return attributedText
    }
    
    // 获取截取后的文本，确保不超过最大宽度
    private func getTruncatedText(fullText: String, maxWidth: CGFloat, maxHeight: CGFloat) -> String {
        let attributedString = NSAttributedString(string: fullText, attributes: [.font: textFont])
        
        var truncatedText = fullText
        
        // 逐步减少文本长度，直到文本的高度不超过最大高度
        for i in stride(from: fullText.count, to: 0, by: -1) {
            let substring = fullText.prefix(i)
            
            let size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
            let boundingRect = (substring as NSString).boundingRect(
                with: size,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: textFont],
                context: nil
            )
            
            // 如果文本的高度不超过最大高度，说明可以显示
            if boundingRect.height <= maxHeight {
                truncatedText = String(substring)
                break
            }
        }
        
        return truncatedText
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        updateText() // 布局发生变化时重新计算文本
    }
}
