//
//  QuickPaths.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/3/8.
//  Copyright © 2020 Wingto. All rights reserved.

import UIKit
import Foundation

// MARK: - global var and methods
public typealias QPath = QuickPaths

/// 快捷路径方法
public class QuickPaths {

    /// FileManager.default
    public static let fileManager = FileManager.default

    /// Home目录  ./
    public static let homePath = NSHomeDirectory()

    /// Documnets目录 ./Documents
    public static let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first

    /// Library目录   ./Library
    public static let libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first

    /// Library目录   ./Caches
    public static let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first

    /// tmp目录  ./tmp
    public static let tmpPath = NSTemporaryDirectory()

    /// 获取目标文件夹下所有文件的路径
    /// - Parameter path: 目标文件夹路径
    /// - Returns: 文件路径数组
    public static func filePaths(_ path: String) -> [String]? {
        guard path.isEmpty == false else {
            print("目标文件夹路径为空!!!")
            return nil
        }
        var filePaths = [String]()
        do {
            let filenames = try FileManager.default.contentsOfDirectory(atPath: path)
            for fname in filenames {
                var isDir: ObjCBool = true
                let fullPath = "\(path)/\(fname)"
                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                    if !isDir.boolValue {
                        filePaths.append(fullPath)
                    }
                }
            }
        } catch let error as NSError {
            print("获取文件路径列表失败: \(error)")
        }
        return filePaths
    }
    
    /// 创建一个文件夹全路径
    /// - Parameters:
    ///   - basePath: 存放路径
    ///   - dicName: 文件夹名称
    /// - Returns: 全路径
    public static func createDirectory(basePath: String, dicName: String?) -> String {
        let fileBaseUrl = URL.init(fileURLWithPath: basePath)
        var dicPath = fileBaseUrl
        if let dicName = dicName {
            dicPath = fileBaseUrl.appendingPathComponent(dicName)
        }
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: dicPath.path) == false {
            do {
                try fileManager.createDirectory(atPath: dicPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("文件夹路径创建失败!")
            }
        }
        return dicPath.path
    }
    
    /// 创建空文件
    /// - Parameters:
    ///   - filePath: 文件路径
    ///   - contents: 默认写入空字符串
    public static func createFile(filePath: String, contents: Any = "") {
        let exist = FileManager.default.fileExists(atPath: filePath)
        if !exist {
            //let data = Data(base64Encoded:"aGVsbG8gd29ybGQ=" ,options:.ignoreUnknownCharacters)
            var appendedData = Data()
            if let contents = contents as? String {
                appendedData = contents.data(using: String.Encoding.utf8, allowLossyConversion: true)!
            } else if let contents = contents as? UIImage {
                appendedData = contents.pngData()!
            } else if let contents = contents as? Data {
                appendedData = contents
            }
            let createSuccess = FileManager.default.createFile(atPath: filePath, contents: appendedData, attributes:nil)
            print("文件创建结果: \(createSuccess)")
        }
    }
    
    /// 文件内末尾写入
    /// - Parameters:
    ///   - filePath: 文件路径
    ///   - contents: 写入内容
    public static func writingToFile(filePath:String, contents: String) {
        guard let appendedData = contents.data(using: String.Encoding.utf8, allowLossyConversion: true) else { return }
        if let writeHandler = try? FileHandle(forWritingTo: URL.init(fileURLWithPath: filePath)) {
            writeHandler.seekToEndOfFile()
            writeHandler.write(appendedData)
        }
    }
    
    /// 文件删除操作
    /// - Parameter model: 图片模型
    public static func removeFile(_ path: String) {
        guard path.isEmpty == false else {
            print("目标文件路径为空!!!")
            return
        }
        do {
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
                print("Successfully deleted file: \(path)")
            } else {
                print("File does not exist: \(path)")
            }
        } catch {
            print("文件path:\(path)删除失败!")
        }
    }
    
    /// 删除文件夹下所有内容, 递归删除
    public static func deleteFolder(_ path: String) {
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(atPath: path)
            for file in files {
                let fullPath = "\(path)/\(file)"
                if fileManager.fileExists(atPath: fullPath) {
                    if fileManager.isDeletableFile(atPath: fullPath) {
                        try fileManager.removeItem(atPath: fullPath)
                    } else {
                        deleteFolder(fullPath)
                    }
                }
            }
            try fileManager.removeItem(atPath: path)
        } catch {
            print("Error deleting folder: \(error)")
        }
    }
}
