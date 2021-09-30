//
//  LoggerManager.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/30.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import CocoaLumberjack

//MARK: - global var and methods
private let KdateFormatString = "yyyy/MM/dd HH:mm:ss"

//MARK: - main class
class LoggerManager {

    static let shared = LoggerManager()
    
    /// 存7天
    lazy var fileLogger: DDFileLogger = {
        let _fileLogger = DDFileLogger.init()
        _fileLogger.rollingFrequency = 60 * 60 * 24
        _fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        _fileLogger.logFormatter = LoggerFormatter.init()
        return _fileLogger
    }()
    
    func launch() {
        if #available(iOS 10.0, *) {
            // Uses os_log
            DDLog.add(DDOSLogger.sharedInstance)
        } else {
            // TTY = Xcode 控制台
            // DDTTYLogger，你的日志语句将被发送到 Xcode 控制台
            DDLog.add(DDTTYLogger.sharedInstance!) // TTY = Xcode console
        }
        //DDLog.add(DDASLLogger.sharedInstance)  // ASL = Apple System Logs
        DDLog.add(fileLogger)

//        DDLogVerbose("Verbose");
//        DDLogDebug("Debug");
//        DDLogInfo("Info");
//        DDLogWarn("Warn");
//        DDLogError("Error");
    }
}

//MARK: - private mothods
extension LoggerManager {
    
}

//MARK: - call backs
extension LoggerManager {
    
}

//MARK: - delegate or data source
extension LoggerManager {
    
}

//MARK: - other classes

class LoggerFormatter: NSObject, DDLogFormatter {
    
    var atomicLoggerCounter: DDAtomicCounter?
    var threadUnsafeDateFormatter: DateFormatter?
    
    func format(message logMessage: DDLogMessage) -> String? {
        var level = ""
        switch logMessage.flag {
        case .error:
            level = "Error"
            break
        case .warning:
            level = "Warning"
            break
        case .info:
            level = "Info"
            break
        case .debug:
            level = "Debug"
            break
        default:
            level = "Verbose"
            break
        }
        let time = self.stringFromDate(date: logMessage.timestamp)
        let message = logMessage.message
        let format = level + time + "|" + message
        return format
    }
    
    func stringFromDate(date: Date) -> String {
        let count = atomicLoggerCounter?.value()
        if count ?? 0 <= 1 {
            // Single-threaded mode.
            if (threadUnsafeDateFormatter == nil) {
                threadUnsafeDateFormatter = DateFormatter.init()
                threadUnsafeDateFormatter?.date(from: KdateFormatString)
            }
            return threadUnsafeDateFormatter?.string(from: date) ?? ""
        } else {
            // Multi-threaded mode.
            // NSDateFormatter is NOT thread-safe.
            let key = "LoggerFormatter_DateFormatter"
            let threadDict = Thread.current.threadDictionary
            if let dateFormatter = threadDict.object(forKey: key) as? DateFormatter {
                return dateFormatter.string(from: date)
            } else {
                let dateFormatter = DateFormatter.init()
                dateFormatter.date(from: KdateFormatString)
                threadDict.setObject(dateFormatter, forKey: key as NSCopying)
                return dateFormatter.string(from: date)
            }
        }
    }
    
    func didAdd(to logger: DDLogger) {
        atomicLoggerCounter?.increment()
    }
    
    func willRemove(from logger: DDLogger) {
        atomicLoggerCounter?.decrement()
    }
}
