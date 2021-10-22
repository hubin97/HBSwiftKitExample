//
//  ThemeStyle.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/4/20.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import UIKit

// MARK: - global var and methods
/**
 #if kiOS12Later
 case unspecified = 0//UIUserInterfaceStyle.un
 case light = 1
 case dark = 2
 #else
 case unspecified = 0
 case light = 1
 case dark = 2
 #endif
 */
public enum ThemeMode: String {
//    case unspecified // = 0
    case light // = 1
    case dark  // = 2
    case main  // = 3

//    enum theme_light {
//        static var color1 = UIColor.red
//        static var color2 = UIColor.green
//        static var color3 = UIColor.blue
//    }
    static var mode = ThemeMode(rawValue: ThemeMode.light.rawValue)

    public func setColors(bind colors: [String]) {
        if UserDefaults.standard.bool(forKey: "ThemeMode") == false {
            UserDefaults.standard.setValue(colors, forKey: self.rawValue)
            UserDefaults.standard.setValue([self.rawValue], forKey: "modes")
            UserDefaults.standard.setValue(true, forKey: "ThemeMode")
        } else {
            if let modes = UserDefaults.standard.value(forKey: "modes") as? [String],
               let firstColors = UserDefaults.standard.value(forKey: modes.first ?? "") as? [String] {
                assert(firstColors.count == colors.count, "主题下颜色数组元素不统一")
                var newmodes = modes
                newmodes.append(self.rawValue)
                UserDefaults.standard.setValue(newmodes, forKey: "modes")
                UserDefaults.standard.setValue(colors, forKey: self.rawValue)
            }
        }
        UserDefaults.standard.synchronize()
    }

    public func themes() -> [ThemeMode]? {
        guard UserDefaults.standard.bool(forKey: "ThemeMode") == true else { return nil }
        guard let modes = UserDefaults.standard.value(forKey: "modes") as? [String] else { return nil }
        return modes.map({ (ThemeMode.init(rawValue: $0)!) })
    }

    public static func dynamicColor(idx: Int) -> String? {
        if let colors = UserDefaults.standard.value(forKey: ThemeMode.mode?.rawValue ?? ThemeMode.light.rawValue) as? [String], colors.count > idx {
            return colors[idx]
        }
        return nil
    }
}

// MARK: - main class

public class ThemeStyle {

}

// MARK: - private mothods
extension ThemeStyle {

}

// MARK: - call backs
extension ThemeStyle {

}

// MARK: - delegate or data source
extension ThemeStyle {

}

// MARK: - other classes
