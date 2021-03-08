//
//  QuickPaths.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/3/8.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

//MARK: - global var and methods
/// Home目录  ./
public let homePath = NSHomeDirectory()

/// Documnets目录 ./Documents
public let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first

/// Library目录   ./Library
public let libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first

/// Library目录   ./Caches
public let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first

/// tmp目录  ./tmp
public let tmpPath = NSTemporaryDirectory()

//MARK: -


//MARK: - main class
public typealias QPath = QuickPaths

/// 快捷路径方法
public class QuickPaths {

    /// 获取目标文件夹下所有文件的路径
    /// - Parameter path: 目标文件夹路径
    /// - Returns: 文件路径数组
    public static func filePaths(_ path: String) -> [String]? {
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
    /// - Parameter suffix: 传入一个指定的后缀
    func createFile(suffix: String?) -> String {
        var configPath = documentPath ?? ""
        if let suffixPath = suffix {
            configPath = "\(configPath)/\(suffixPath)"
        }
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: configPath) == false {
            do {
                try fileManager.createDirectory(atPath: configPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("文件夹路径创建失败!")
            }
            
        }
        return configPath
    }

    /// 文件删除操作
    /// - Parameter model: 图片模型
    public static func removeFile(_ path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print("文件path:\(path)删除失败!")
        }
    }
}

//MARK: - private mothods
extension QuickPaths {
    
}

//MARK: - call backs
extension QuickPaths {
    
}

//MARK: - delegate or data source
extension QuickPaths {
    
}

//MARK: - other classes
