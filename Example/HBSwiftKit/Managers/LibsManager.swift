//
//  LibsManager.swift
//  Momcozy
//
//  Created by hubin.h on 2024/5/13.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import IQKeyboardManagerSwift
import Toast_Swift
import ProgressHUD
import Kingfisher
import CocoaLumberjack
//import Bugly
import MMKV
import FLEX

// MARK: - global var and methods

// MARK: - main class
class LibsManager {
    
    static let shared = LibsManager()
    
    func setupLibs() {
        let libsManager = LibsManager.shared
        libsManager.setupMMKV()
        libsManager.setupBugly()
        libsManager.setupToast()
        libsManager.setupProgressHUD()
        libsManager.setupKeyboardManager()
        libsManager.setupKingfisher()
        libsManager.setupLogger()
        //libsManager.setupTuya()
        libsManager.setupFLEXManager()
    }
}

// MARK: - private mothods
extension LibsManager {
    
    func setupMMKV() {
        MMKVManager.shared.initMMKV()
    }
    
    func setupBugly() {
        //Bugly.start(withAppId: "xxx")
    }
    
    func setupToast() {
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.duration = 2.0
        ToastManager.shared.position = .center
        ToastManager.shared.style.cornerRadius = 5
        ToastManager.shared.style.backgroundColor = .systemGroupedBackground
    }
    
    func setupProgressHUD() {      
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.colorStatus = .systemBlue
        ProgressHUD.fontStatus = UIFont.systemFont(ofSize: 16)
        ProgressHUD.colorProgress = .systemBlue
        ProgressHUD.animationType = .circleStrokeSpin
        //ProgressHUD.imageSuccess = R.image.icon_hud_success()!
        //ProgressHUD.imageError = R.image.icon_hud_error()!
    }
    
    func setupKeyboardManager() {
        IQKeyboardManager.shared.enable = true
    }
 
    func setupKingfisher() {
        // 设置默认缓存的最大磁盘缓存大小。 默认值为0，表示没有限制。// 500 MB
        ImageCache.default.diskStorage.config.sizeLimit = UInt(500 * 1024 * 1024)
        // 设置缓存在磁盘中存储的最长时间。 默认值为 1 周
        ImageCache.default.diskStorage.config.expiration = .days(7)
        // 设置默认图像下载器的超时时间。 默认值为 15 秒。
        ImageDownloader.default.downloadTimeout = 15.0
    }

    func setupCocoaLumberjack() {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
    func setupFLEXManager() {
        //FLEXManager.shared.showExplorer()
    }
    
    // 开启日志管理
    func setupLogger() {
        let logLevel = DDLogLevel.debug
#if DEBUG
        LogM.shared.launch(logLevel).entrance()
#else
        LogM.shared.launch(logLevel)
#endif
    }
}

// MARK: - call backs
extension LibsManager { 
}

// MARK: - delegate or data source
extension LibsManager { 
}

// MARK: - other classes
