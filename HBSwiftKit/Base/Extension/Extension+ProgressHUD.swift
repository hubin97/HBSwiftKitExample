//
//  Extension+ProgressHUD.swift
//  LuteBase
//
//  Created by hubin.h on 2024/11/7.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import ProgressHUD

/// ProgressHUD扩展
extension ProgressHUD {
    
    /// 计算显示时长
    private static func duration(_ content: String, minDuration: TimeInterval = 1.0) -> TimeInterval {
        return max(Double(content.count) * 0.06 + 0.5, 1)
    }

    /// 显示加载中
    /// - Parameters:
    ///   - status: 文本
    ///   - interaction: 是否允许交互
    ///   - delayDismss: 延时隐藏
    ///   - completion: 完成回调
    public static func showLoading(_ status: String? = nil, interaction: Bool = false, delayDismss: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        ProgressHUD.animate(status, interaction: interaction)
        
        if let delay = delayDismss {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                ProgressHUD.dismiss()
                completion?()
            }
        }
    }
    
    /// 显示进度
    /// - Parameters:
    ///   - text: 文本
    ///   - value: 进度值 0.0-1.0
    ///   - interaction: 是否允许交互
    ///   - completion: 完成回调
    public static func showProgress(_ text: String? = nil, _ value: CGFloat, interaction: Bool = false, completion: (() -> Void)? = nil) {
        ProgressHUD.progress(text, value, interaction: interaction)
        
        if value >= 1 {
            completion?()
        }
    }

    /// 显示成功提示
    /// - Parameters:
    ///   - status: 文本
    ///   - delay: 延时隐藏
    ///   - completion: 完成回调
    public static func showSuccess(_ status: String?, interaction: Bool = false, delay: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        let delay = delay ?? duration(status ?? "")
        ProgressHUD.success(status, interaction: interaction, delay: delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            completion?()
        }
    }
    
    /// 显示失败提示
    /// - Parameters:
    ///   - status: 文本
    ///   - delay: 延时隐藏
    ///   - completion: 完成回调
    public static func showError(_ status: String?, interaction: Bool = false, delay: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        let delay = delay ?? duration(status ?? "")
        ProgressHUD.error(status, interaction: interaction, delay: delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            completion?()
        }
    }
    
    /// 隐藏提示
    /// - Parameters:
    ///   - delay: 延时隐藏
    ///   - completion: 隐藏回调
    public static func dismiss(delay: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        if let delay = delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                ProgressHUD.dismiss()
                completion?()
            }
            return
        }
        ProgressHUD.dismiss()
    }
}
