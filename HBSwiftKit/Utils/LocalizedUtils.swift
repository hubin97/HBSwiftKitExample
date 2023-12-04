//
//  LocalizedUtils.swift
//  Momcozy
//
//  Created by hubin.h on 2023/11/17.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

// MARK: - global var and methods
let localizedKey = "language"

extension String {
    /// 本地国际化
    public var localized: String {
        if let currentLanguage = UserDefaults.standard.string(forKey: localizedKey),
           let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"), let bundle = Bundle(path: path) {
            return NSLocalizedString(self, bundle: bundle, value: "", comment: "")
        }
        return NSLocalizedString(self, bundle: .main, value: "", comment: "")
    }
}

// MARK: - main class
open class LocalizedUtils {
    
    /// 语言代码
    public enum LanguageCode: String {
        /// 英语
        case en
        /// 中文
        case zh_Hans = "zh-Hans"
        /// 法语
        case fr
        /// 德语
        case de
        /// 意大利语
        case it
        /// 西班牙语
        case es
        
        /// 代码语言映射关系
        var name: String {
            switch self {
            case .en:
                return "English"
            case .fr:
                return "Français"
            case .de:
                return "Deutsch"
            case .it:
                return "Italiano"
            case .es:
                return "Español"
            case .zh_Hans:
                return "中文"
            }
        }
    }
    
    /// 获取主窗口
    private static let keyWindow: UIWindow? = {
        if #available(iOS 13, *) {
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        } else {
            UIApplication.shared.keyWindow
        }
    }()
    
    /// 更新本地国际化
    /// - Parameters:
    ///   - identity: 语言代码
    ///   - rootVc: 重启根控制器
    public static func updateLocalized(_ identity: LanguageCode, with rootVc: UIViewController) {
        if let currentLanguage = UserDefaults.standard.string(forKey: localizedKey), currentLanguage != identity.rawValue {
            print("切换本地化语言---")
            UserDefaults.standard.set(identity.rawValue, forKey: localizedKey)
            UserDefaults.standard.synchronize()
            keyWindow?.rootViewController = rootVc
        }
    }
    
    /// 获取系统语言方法
    /// https://blog.csdn.net/wsyx768/article/details/128265245
    /// - Returns: 语言代码
    public static func systemLanguage() -> String {
        guard let preferredLang = NSLocale.preferredLanguages.first else { return "en" }
        
        /// 匹配前缀,  无匹配的默认为英语
        if preferredLang.hasPrefix("zh-Hans") || preferredLang.hasPrefix("zh-Hant") {
            return "zh-Hans"
        } else if preferredLang.hasPrefix("en-") {
            return "en"
        } else if preferredLang.hasPrefix("fr-") {
            return "fr"
        } else if preferredLang.hasPrefix("de-") {
            return "de"
        } else if preferredLang.hasPrefix("it-") {
            return "it"
        } else if preferredLang.hasPrefix("es-") {
            return "es"
        } else {
            return "en"
        }
    }
}
