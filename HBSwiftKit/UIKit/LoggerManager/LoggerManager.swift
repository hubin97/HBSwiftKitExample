//
//  LoggerManager.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/30.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import CocoaLumberjack

//MARK: - global var and methods
//private let KdateFormatString = "yyyy/MM/dd HH:mm:ss"

//MARK: - main class
open class LoggerManager {

    public static let shared = LoggerManager()
    
    // 定义Log等级 *  Error, warning, info, debug and verbose logs
    public var logLevel: DDLogLevel = .debug

    /// 存7天
    open lazy var fileLogger: DDFileLogger = {
        let _fileLogger = DDFileLogger.init()
        //重用log文件，不要每次启动都创建新的log文件(默认值是false)
        _fileLogger.doNotReuseLogFiles = false
        //禁用文件大小滚动
        _fileLogger.maximumFileSize = 0
        //log文件在24小时内有效，超过时间创建新log文件(默认值是24小时)
        _fileLogger.rollingFrequency = 60 * 60 * 24
        //最多保存7个log文件
        _fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        //log文件夹最多保存20M
        _fileLogger.logFileManager.logFilesDiskQuota = 1024 * 1024 * 20
        _fileLogger.logFormatter = LoggerFormatter.init()
        return _fileLogger
    }()
    
    /// 开启日志记录
    @discardableResult
    public func launch() -> Self {
        if #available(iOS 10.0, *) {
            // Uses os_log
            DDLog.add(DDOSLogger.sharedInstance)
        } else {
            // TTY = Xcode 控制台
            // DDTTYLogger，你的日志语句将被发送到 Xcode 控制台
            DDLog.add(DDTTYLogger.sharedInstance!) // TTY = Xcode console
            DDLog.add(DDASLLogger.sharedInstance)  // ASL = Apple System Logs
        }
        DDLog.add(fileLogger)
        return self
    }
    
    /// 初始化日志入口
    public func entrance() {
        LoggerAssistant.init(icon: UIImage.bundleImage(named: "logger")) {
            keyViewController()?.navigationController?.pushViewController(LoggerListController(), animated: true)
        }.show()
    }
    
    /// 移除日志入口
    public func removeEntrance() {
        UIApplication.shared.delegate?.window??.subviews.first(where: { $0.isKind(of: LoggerAssistant.classForCoder()) })?.removeFromSuperview()
    }
}

extension LoggerManager {
    
    public static func logError(_ message: String) {
        DDLogError(message)
    }
    
    public static func logWarn(_ message: String) {
        DDLogWarn(message)
    }
    
    public static func logInfo(_ message: String) {
        DDLogInfo(message)
    }
    
    public static func logDebug(_ message: String) {
        DDLogDebug(message)
    }
    
    public static func logVerbose(_ message: String) {
        DDLogVerbose(message)
    }
}

//MARK: - other classes

open class LoggerFormatter: NSObject, DDLogFormatter {
    
    open lazy var dateFormatter: DateFormatter = {
        let _dateFormatter = DateFormatter.init()
        _dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        _dateFormatter.timeZone = TimeZone.current
        return _dateFormatter
    }()
    
    open func format(message logMessage: DDLogMessage) -> String? {
        guard logMessage.flag.rawValue < LoggerManager.shared.logLevel.rawValue else { return nil }
        
        var flag = ""
        switch logMessage.flag {
        case .error:
            flag = "❌"
            break
        case .warning:
            flag = "⚠️"
            break
        case .info:
            flag = "I"
            break
        case .debug:
            flag = "D"
            break
        default:
            flag = "V" // Verbose
            break
        }
        let time = dateFormatter.string(from: Date())
        let message = logMessage.message
        let format = "[\(time)] " + "[\(flag)] " + message
        return format
    }
    
//    var atomicLoggerCounter: DDAtomicCounter?
//    var threadUnsafeDateFormatter: DateFormatter?
//
//    func format(message logMessage: DDLogMessage) -> String? {
//        var level = ""
//        switch logMessage.flag {
//        case .error:
//            level = "Error"
//            break
//        case .warning:
//            level = "Warning"
//            break
//        case .info:
//            level = "Info"
//            break
//        case .debug:
//            level = "Debug"
//            break
//        default:
//            level = "Verbose"
//            break
//        }
//        let time = self.stringFromDate(date: logMessage.timestamp)
//        let message = logMessage.message
//        let format = level + time + "|" + message
//        return format
//    }
//
//    func stringFromDate(date: Date) -> String {
//        let count = atomicLoggerCounter?.value()
//        if count ?? 0 <= 1 {
//            // Single-threaded mode.
//            if (threadUnsafeDateFormatter == nil) {
//                threadUnsafeDateFormatter = DateFormatter.init()
//                threadUnsafeDateFormatter?.date(from: KdateFormatString)
//            }
//            return threadUnsafeDateFormatter?.string(from: date) ?? ""
//        } else {
//            // Multi-threaded mode.
//            // NSDateFormatter is NOT thread-safe.
//            let key = "LoggerFormatter_DateFormatter"
//            let threadDict = Thread.current.threadDictionary
//            if let dateFormatter = threadDict.object(forKey: key) as? DateFormatter {
//                return dateFormatter.string(from: date)
//            } else {
//                let dateFormatter = DateFormatter.init()
//                dateFormatter.date(from: KdateFormatString)
//                threadDict.setObject(dateFormatter, forKey: key as NSCopying)
//                return dateFormatter.string(from: date)
//            }
//        }
//    }
//
//    func didAdd(to logger: DDLogger) {
//        atomicLoggerCounter?.increment()
//    }
//
//    func willRemove(from logger: DDLogger) {
//        atomicLoggerCounter?.decrement()
//    }
}
