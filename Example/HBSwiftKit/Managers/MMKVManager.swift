//
//  MMKVManager.swift
//  Momcozy
//
//  Created by hubin.h on 2024/9/18.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import MMKV

// MARK: - 全局 MMKV 实例
/// `注意必须在初始化之后使用`
let mmkv: MMKV = {
    /// 初始化 MMKV 设置 加密Key, 以及 模式 为单一进程
    let mmkv = MMKV.init(mmapID: MMKVKeys.bundle_id.rawValue, cryptKey: MMKVKeys.bundle_id.rawValue.data, mode: .singleProcess)
    return mmkv ?? MMKV.default()!
}()

// MARK: 定义 MMKV 键的枚举
// TODO: 除AuthManager以外的其他地方数据都将进行迁移(包括 DataManager, CacheManager等 非用户数据的)
enum MMKVKeys: String {
    case bundle_id = "com.xx.xxx"
    /// 迁移 版本号
    case migrateVersion
    /// 欢迎引导页
    case welcome
    /// 协议版本
    case pversion
    //TODO: 添加更多的键
}

// MARK: - MMKVManager
class MMKVManager {
    /// 实例化
    static let shared = MMKVManager()
    
    func initMMKV() {
        // 初始化 MMKV
        MMKV.initialize(rootDir: nil, logLevel: .none)
    
        // 获取默认的 NSUserDefaults 实例
        let userDefaultsDictionary = UserDefaults.standard.dictionaryRepresentation()
                
        /// 应该添加迁移限制条件,
        /// 1. 当前版本号 小于等于 `1.7.6`的时候才迁移,
        /// 2. 如果迁移过了则不迁移
        /// 3. 迁移完成后, 记录版本号
        let migrateVersion = mmkv.string(forKey: MMKVKeys.migrateVersion.rawValue)
        if let appVersion = kAppVersion, migrateVersion == nil && appVersion.compare("1.7.6", options: .numeric) != .orderedDescending {
            // 从 NSUserDefaults 迁移数据到 MMKV
            //mmkv.migrateFrom(userDefaults: UserDefaults.standard)
            mmkv.migrateFrom(userDefaultsDictionaryRepresentation: userDefaultsDictionary)
            // 更新版本信息
            mmkv.set(appVersion, forKey: MMKVKeys.migrateVersion.rawValue)
            // 记录迁移日志
            print("数据迁移完成，当前版本: \(appVersion)")
            // 迁移完成后，可以选择删除 NSUserDefaults 中的键值对
            // userDefaults.removeObject(forKey: "yourKey")
            // userDefaults.synchronize()
        } else {
            print("不需要迁移数据，当前版本: \(kAppVersion ?? "")，已迁移版本: \(String(describing: migrateVersion))")
        }
        
        // 数据验证
        //printMMKVData()
    }
}

// MARK: - private mothods
extension MMKVManager {
    
    /// `数据迁移校验`
    func printMMKVData() {
        if let welcome = mmkv.string(forKey: MMKVKeys.welcome.rawValue) {
            print("welcome: \(welcome)")
        }
        
        if let pversion = mmkv.string(forKey: MMKVKeys.pversion.rawValue) {
            print("pversion: \(pversion)")
        }
    }
}
