//
//  MarqueeLabel.swift
//  Momcozy
//
//  Created by hubin.h on 2024/12/18.

import Foundation

// MARK: MarqueeLabel
class MarqueeLabel: UILabel {
    
    // 可调节的滚动速度
    var scrollSpeed: CGFloat = 1 {
        didSet {
            resetScrolling()  // 当滚动速度更改时，重新开始滚动
        }
    }

    // 控制是否启用走马灯
    var isMarqueeEnabled: Bool = false {
        didSet {
            if isMarqueeEnabled {
                // 限制文案宽度不够不用滚动
                if canMarquee {
                    startScrolling()
                }
            } else {
                stopScrolling()
                resetToStartPosition()
            }
        }
    }
    
    /// 是否可以走马灯
    var canMarquee: Bool {
        return textWidth > labelWidth
    }
    
    private var scrollingTimer: Timer?
    private var textWidth: CGFloat = 0
    private var labelWidth: CGFloat = 0
    private var currentX: CGFloat = 0
    private var isScrolling: Bool = false

    // 自定义的走马灯效果需要的初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // 走马灯初始化
    private func commonInit() {
        self.numberOfLines = 1
        self.lineBreakMode = .byTruncatingTail
        self.clipsToBounds = true
        self.isScrolling = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 获取 UILabel 的宽度
        labelWidth = self.bounds.width
        textWidth = (self.text! as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.bounds.height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font!], context: nil).width
        
        // 如果文本宽度大于 Label 宽度，则启动滚动
        if canMarquee && isMarqueeEnabled {
            startScrolling()
        } else {
            stopScrolling()
        }
    }
    
    // 启动滚动
    private func startScrolling() {
        if !isScrolling {
            isScrolling = true
            currentX = 0  // 初始位置从最左侧开始
            // 每 0.01 秒更新一次文本位置
            scrollingTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateScrolling), userInfo: nil, repeats: true)
            RunLoop.main.add(scrollingTimer!, forMode: .common)
        }
    }
    
    // 停止滚动
    private func stopScrolling() {
        isScrolling = false
        scrollingTimer?.invalidate()
        scrollingTimer = nil
    }
    
    // 重新启动滚动
    private func resetScrolling() {
        stopScrolling()
        startScrolling()
    }

    // 重置到初始位置
    private func resetToStartPosition() {
        currentX = 0  // 确保文本从最左侧开始
        setNeedsDisplay()  // 强制重新绘制文本
    }
    
    // 更新滚动位置
    @objc private func updateScrolling() {
        // 每次更新文本的位置
        currentX -= scrollSpeed
        if currentX + textWidth < 0 {
            currentX = labelWidth  // 重置位置到最左侧，继续循环
        }
        
        setNeedsDisplay()
    }
    
    // 自定义绘制文本区域，控制文本滚动
    override func drawText(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        
        // 设置文本的绘制位置
        let drawRect = CGRect(x: currentX, y: 0, width: textWidth, height: rect.height)
        super.drawText(in: drawRect)
        
        context.restoreGState()
    }
    
    // 在控件销毁时停止滚动
    deinit {
        stopScrolling()
    }
}
