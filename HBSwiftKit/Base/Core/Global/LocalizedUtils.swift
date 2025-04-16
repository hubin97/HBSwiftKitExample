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
        guard let currentLanguage = UserDefaults.standard.string(forKey: localizedKey),
              let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"), let bundle = Bundle(path: path),
              let enPath = Bundle.main.path(forResource: "en", ofType: "lproj"), let enBundle = Bundle(path: enPath) else {
            return NSLocalizedString(self, bundle: .main, value: "", comment: "")
        }
        let currentLocalized = NSLocalizedString(self, bundle: bundle, value: "", comment: "")
        let defaultLocalized = NSLocalizedString(self, bundle: enBundle, value: "", comment: "")
        //FIXME: 当返回的字符串和key一致时, 则返回 默认语言
        if self == currentLocalized {
            return defaultLocalized
        }
        return currentLocalized
    }
    
    public func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
}

extension StaticString {
    /// 本地国际化, `R.string.localizable.login_Login.key.localized`
    public var localized: String {
        return description.localized
    }
    
    public func localizedFormat(_ arguments: CVarArg...) -> String {
        return description.localizedFormat(arguments)
    }
}

// MARK: - main class
open class LocalizedUtils {
    
    /// 语言代码
    public enum LanguageCode: String {
        /// 英语
        case en
        /// 中文
        case cn = "zh-Hans"
        /// 法语
        case fr
        /// 德语
        case de
        /// 意大利语
        case it
        /// 西班牙语
        case es
        /// 阿拉伯语
        case ar

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
            case .ar:
                return "عربي"
            case .cn:
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
    ///   - hander: 回调
    public static func updateLocalized(_ identity: LanguageCode, hander: @escaping (() -> Void)) {
        guard currentLanguage() != identity.rawValue else { return }
        print("切换本地化语言---")
        UserDefaults.standard.set(identity.rawValue, forKey: localizedKey)
        UserDefaults.standard.synchronize()
        hander()
    }
    
    /// 设置系统语言为当前语言
    public static func setupLocalized() {
        UserDefaults.standard.set(LocalizedUtils.systemLanguage(), forKey: localizedKey)
        UserDefaults.standard.synchronize()
    }
    
    /// 当前语言
    public static func currentLanguage() -> LanguageCode.RawValue {
        return UserDefaults.standard.string(forKey: localizedKey) ?? systemLanguage()
    }
    
    /// 是否为中国🇨🇳
    public static func isChina() -> Bool {
        return currentLanguage() == LanguageCode.cn.rawValue
    }
    
    /// 是否为`RTL`语言; `阿拉伯语, 希伯来语, 波斯语, 希伯来语等`
    public static func isRTL() -> Bool {
        //FIXME: 目前仅判断 阿拉伯语
        return currentLanguage() == LanguageCode.ar.rawValue
    }

    /// 获取系统语言方法
    /// https://blog.csdn.net/wsyx768/article/details/128265245
    /// - Returns: 语言代码
    public static func systemLanguage() -> String {
        guard let preferredLang = NSLocale.preferredLanguages.first else { return "en" }
        
        /// 匹配前缀,  无匹配的默认为英语
//        if preferredLang.hasPrefix("zh-Hans") {
//            return "zh-Hans"
//        } else if preferredLang.hasPrefix("zh-Hant") {
//            return "zh-Hant"

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
        } else if preferredLang.hasPrefix("ar-") {
            return "ar"
        } else {
            return "en"
        }
    }
    
    /// `前端i18n格式映射表`
    /// - Parameter code: 传入获取的语言code
    /// - Returns: 隐射返回字段
    public static func mappingLanguageToWeb(_ code: LanguageCode.RawValue = currentLanguage()) -> String {
        // 创建一个映射表，将iOS语言代码转换为前端i18n格式
        let lngMap: [String: String] = [
            "zh-Hans": "zh-CN",
            "zh-Hant": "zh-TW",
            "en": "en-US",
            "fr": "fr-FR",
            "de": "de-DE",
            "it": "it-IT",
            "es": "es-ES",
            "ar": "ar"
        ]
        return (lngMap.value(forKey: code) as? String) ?? "en-US"
    }
}

// MARK: - Date Format
//extension LocalizedUtils {
//    
//    /// 默认时间格式(云端支持格式) `"yyyy-MM-dd"`
//    public static var dateFormat_standard: String {
//        return "yyyy-MM-dd"
//    }
//    
////    /// 默认时间格式(云端支持格式) `"yyyy-MM-dd HH:mm"`
////    static var dateFormat_Cloud2: String {
////        return "yyyy-MM-dd HH:mm"
////    }
////    
////    /// 默认时间格式(云端支持格式) `"yyyy-MM-dd HH:mm:ss"`
////    static var dateFormat_Cloud3: String {
////        return "yyyy-MM-dd HH:mm:ss"
////    }
////    
////    /// 默认时间格式(云端支持格式) `"HH:mm"`
////    static var dateFormat_Cloud4: String {
////        return "HH:mm"
////    }
//    
//    /// 区分语言展示 时间格式 `yyyy/MM/dd`
//    public static var dateFormat_YMD: String {
//        return LocalizedUtils.isChina() || LocalizedUtils.isRTL() ? "yyyy/MM/dd": "MM/dd/yyyy"
//    }
//    
//    /// 区分语言展示 时间格式 `yyyy/MM/dd HH:mm`
//    public static var dateFormat_YMD_HM: String {
//        if LocalizedUtils.isRTL() {
//            return "HH:mm yyyy/MM/dd"
//        }
//        return LocalizedUtils.isChina() ? "yyyy/MM/dd HH:mm": "MM/dd/yyyy HH:mm"
//    }
//    
//    /// 区分语言展示 时间格式 `yyyy/MM/dd HH:mm:ss`
//    public static var dateFormat_YMD_HMS: String {
//        if LocalizedUtils.isRTL() {
//            return "HH:mm:ss yyyy/MM/dd"
//        }
//        return LocalizedUtils.isChina() ? "yyyy/MM/dd HH:mm:ss": "MM/dd/yyyy HH:mm:ss"
//    }
//    
//    /// 时间格式 12 小时制 AP/PM `"hh:mm aa"`
//    public static var dateFormat_hma: String {
//        return "hh:mm aa"
//    }
//}
