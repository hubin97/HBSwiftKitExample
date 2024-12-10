//
//  Button.swift
//  Momcozy
//
//  Created by hubin.h on 2024/8/21.
//  Copyright © 2020 路特创新. All rights reserved.

import UIKit
import RxSwift
import RxCocoa

/// 1. 增加节流防抖机制
/// 
open class Button: UIButton {
    
    /// 设置防抖点击事件的绑定
    func rx_throttledTap(interval: RxTimeInterval = .milliseconds(500)) -> Observable<Void> {
        return self.rx.tap
            .throttle(interval, scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] in
                self?.isEnabled = false // 禁用按钮
                DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                    self?.isEnabled = true // 恢复按钮可用状态
                }
            })
    }
}
