//
//  LoggerManager.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/30.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import CocoaLumberjack

// MARK: - global var and methods
//private let KdateFormatString = "yyyy/MM/dd HH:mm:ss"

public typealias LogM = LoggerManager
// MARK: - main class
open class LoggerManager {

    public static let shared = LoggerManager()
    
    // 定义Log等级 *  Error, warning, info, debug and verbose logs
    public var logLevel: DDLogLevel = .all
    
    // 指定日志存放路径
    public let path = (QuickPaths.documentPath ?? "") + "/Logs"

    /// 存7天
    open lazy var fileLogger: DDFileLogger = {
        // 初始化 日志文件夹的路径
        let _fileLogger = DDFileLogger(logFileManager: DDLogFileManagerDefault(logsDirectory: path))
        // 重用log文件，不要每次启动都创建新的log文件(默认值是false)
        _fileLogger.doNotReuseLogFiles = false
        // 禁用文件大小滚动
        _fileLogger.maximumFileSize = 0
        // log文件在24小时内有效，超过时间创建新log文件(默认值是24小时)
        _fileLogger.rollingFrequency = 60 * 60 * 24
        // 最多保存7个log文件
        _fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        // log文件夹最多保存20M
        _fileLogger.logFileManager.logFilesDiskQuota = 1024 * 1024 * 20
        _fileLogger.logFormatter = LoggerFormatter()
        return _fileLogger
    }()
    
    /// 开启日志记录
    @discardableResult
    public func launch(_ logLevel: DDLogLevel = .all) -> Self {
        self.logLevel = logLevel
        let ddosLogger = DDOSLogger.sharedInstance
        ddosLogger.logFormatter = LoggerFormatter() // 应用自定义的日志格式器
        DDLog.add(ddosLogger) // 添加一个控制台输出的日志记录器
        DDLog.add(fileLogger)
        return self
    }
    
    /// 初始化日志入口
    public func entrance() {
        LoggerAssistant(icon: UIImage.bundleImage(named: "logger")) {
            stackTopViewController()?.navigationController?.pushViewController(LoggerListController(), animated: true)
        }.show()
    }
    
    /// 移除日志入口
    public func removeEntrance() {
        UIApplication.shared.delegate?.window??.subviews.first(where: { $0.isKind(of: LoggerAssistant.classForCoder()) })?.removeFromSuperview()
    }

    /// 是否已展示入口
    public func hasEntrance() -> Bool {
        if let isOn = UserDefaults.standard.object(forKey: "LoggerAssistant") as? Bool {
            return isOn
        }
        return false
    }

    /// 更新入口状态
    /// - Parameter state: 开启/关闭
    public func updateEntrance(_ state: Bool) {
        UserDefaults.standard.set(state, forKey: "LoggerAssistant")
        UserDefaults.standard.synchronize()
    }
}

extension LoggerManager {
    
//    public static func error(_ message: String,
//                             file: StaticString = #file,
//                             function: StaticString = #function,
//                             line: UInt = #line) {
//        DDLogError("\(message)", file: file, function: function, line: line)
//    }
//    
//    public static func warn(_ message: String,
//                            file: StaticString = #file,
//                            function: StaticString = #function,
//                            line: UInt = #line) {
//        DDLogWarn("\(message)", file: file, function: function, line: line)
//    }
//    
//    public static func info(_ message: String,
//                            file: StaticString = #file,
//                            function: StaticString = #function,
//                            line: UInt = #line) {
//        DDLogInfo("\(message)", file: file, function: function, line: line)
//    }
//    
//    public static func debug(_ message: String,
//                             file: StaticString = #file,
//                             function: StaticString = #function,
//                             line: UInt = #line) {
//        DDLogDebug("\(message)", file: file, function: function, line: line)
//    }
//    
//    public static func verbose(_ message: String,
//                               file: StaticString = #file,
//                               function: StaticString = #function,
//                               line: UInt = #line) {
//        DDLogVerbose("\(message)", file: file, function: function, line: line)
//    }
    
    public static func log(_ message: String, level: DDLogLevel = DDDefaultLogLevel, flag: DDLogFlag) {
        DDLog.log(asynchronous: true, level: level, flag: flag, context: 0, file: #file, function: #function, line: #line, tag: nil, format: message, arguments: getVaList([]))
    }
    
    public static func error(_ message: String) {
        log(message, level: .error, flag: .error)
    }
    
    public static func warn(_ message: String) {
        log(message, level: .warning, flag: .warning)
    }
    
    public static func info(_ message: String) {
        log(message, level: .info, flag: .info)
    }
    
    public static func debug(_ message: String) {
        log(message, level: .debug, flag: .debug)
    }
    
    public static func verbose(_ message: String) {
        log(message, level: .verbose, flag: .verbose)
    }
}

///注意: 使用logResourcesCount的`RxSwift.Resources.total` 需要在Podfile中启用资源跟踪 (主工程配置)
/**
 # Enable tracing resources
 installer.pods_project.targets.each do |target|
   if target.name == 'RxSwift'
     target.build_configurations.each do |config|
       if config.name == 'Debug'
         config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
       end
     end
   end
 end
 */
import RxSwift
public func logResourcesCount(enable: Bool = false) {
    #if DEBUG
    if enable {
        LogM.debug("RxSwift resources count: \(RxSwift.Resources.total)")
        
    }
    #endif
}

// MARK: - other classes

open class LoggerFormatter: NSObject, DDLogFormatter {

    open func format(message logMessage: DDLogMessage) -> String? {
        guard logMessage.flag.rawValue <= LoggerManager.shared.logLevel.rawValue else { return nil }

        var flag = ""
        switch logMessage.flag {
        case .error:
            flag = "E❌"
            break
        case .warning:
            flag = "W⚠️"
            break
        case .info:
            flag = "I📝"
            break
        case .debug:
            flag = "D🛠"
            break
        default:
            flag = "🧩"
            break
        }
        let time = logMessage.timestamp.format(with: "yyyy-MM-dd HH:mm:ss.SSS")
        let message = logMessage.message
        let format = "[\(time)] [\(flag)]" + " " +  "[\(logMessage.threadID)][\(logMessage.fileName):\(logMessage.line) \(logMessage.function ?? "")]" + " " + message
        return format
    }
}
