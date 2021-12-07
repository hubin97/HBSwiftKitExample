//
//  SignalMarkView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/12/7.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit

// MARK: - global var and methods

// MARK: - main class
class SignalMarkView: UIView {

    var cTimer: Timer?
    var count = 0
    var totalTime = 0
    private let duration = 0.25
    let markSize = kScaleW(7)
    let markPadding = kScaleW(15)
    let markColors = ["#6588FF", "#FF8D3A", "#FFC742", "#FF4343"]
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bounds = CGRect(x: 0, y: 0, width: (markSize + markPadding) * CGFloat(markColors.count) + 2 * markPadding, height: 2 * markPadding + markSize)
        markColors.enumerated().forEach { (index, color) in
            let btn = UIButton.init(type: .custom)
            btn.frame = CGRect(x: markPadding + (markPadding + markSize) * CGFloat(index), y: markPadding, width: markSize, height: markSize)
            self.addSubview(btn)
            btn.setRectCorner(radiiSize: markSize/2)
            btn.backgroundColor = index == 0 ? UIColor(hexStr: color): UIColor(hexStr: color, alpha: 0.2)
            btn.tag = 1000 + index
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - private mothods
extension SignalMarkView {

    func startAnimate(_ totalTime: Int = 20, completeHandle: (() -> Void)? = nil) {
        self.totalTime = totalTime
        self.count = 0
        cTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(eventHandle), userInfo: nil, repeats: true)
    }

    @objc func eventHandle() {
        if count >= Int(Double(totalTime)/duration) {
            self.freeTimer()
            return
        }
        let idx = count%markColors.count
        let tag = idx + 1000
        self.subviews.forEach { view in
            if let btn = view as? UIButton {
                let color = self.markColors[btn.tag - 1000]
                btn.backgroundColor = btn.tag == tag ? UIColor(hexStr: color): UIColor(hexStr: color, alpha: 0.2)
            }
        }
        count += 1
    }

    func freeTimer() {
        self.cTimer?.invalidate()
        self.cTimer = nil
    }

    func resultMark(_ idx: Int) {
        self.freeTimer()
        self.subviews.forEach { view in
            if let btn = view as? UIButton {
                let color = self.markColors[idx]
                btn.backgroundColor = btn.tag == (idx + 1000) ? UIColor(hexStr: color): UIColor(hexStr: color, alpha: 0.2)
            }
        }
    }

}
