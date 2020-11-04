//
//  NetworkExtension.swift
//  test
//
//  Created by hubin.h@wingto.cn on 2020/8/10.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation
import CoreLocation
import SystemConfiguration.CaptiveNetwork

class NetworkExtension {

    ///
    static let share = NetworkExtension()
    
    var wifiInfo: Dictionary<String, Any>?
    var ssid: String?
    
    // MARK: - Access WiFi Information
    /// 注意clManager不使用全局,则系统权限弹框自动消息(根本点不到好吧)
    // 这里NetworkExtension都得被强引用
    var clManager: CLLocationManager?
    func getWiFiInfo() {
        
        // iOS > 12 Capabilities必须添加 Access WiFi Information (Xcode11这个免费账号貌似没有这项可选)
        // 另外iOS > 13 注意info.plist定位权限配置
        /**
         <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
         <string>获取网络信息需要使用您的位置信息</string>
         <key>NSLocationAlwaysUsageDescription</key>
         <string>获取网络信息需要使用您的位置信息</string>
         <key>NSLocationUsageDescription</key>
         <string>获取网络信息需要使用您的位置信息</string>
         <key>NSLocationWhenInUseUsageDescription</key>
         <string>获取网络信息需要使用您的位置信息</string>
         */
        if #available(iOS 13.0, *) {
            if CLLocationManager.authorizationStatus() == .denied {
                // 提示弹框可跳转至当前应用的系统设置页面
                let alert = Wto_AlertView.init(title: "提示", message: "获取WiFi信息需要开启定位, 是否去设置?")
                alert.addAction("取消", tapAction: nil)
                alert.addAction("去设置") {
                    let settingUrl = NSURL(string: UIApplication.openSettingsURLString)
                    if UIApplication.shared.canOpenURL(settingUrl! as URL) {
                        UIApplication.shared.openURL(settingUrl! as URL)
                    }
                }
                alert.show()
                return
            }
        }
        
        if CLLocationManager.locationServicesEnabled() == false || CLLocationManager.authorizationStatus() == .notDetermined {
            // 拉出系统弹框提示用户是否开启位置权限
            self.clManager = CLLocationManager.init()
            self.clManager?.requestAlwaysAuthorization()
        }
        
        if let cfas: NSArray = CNCopySupportedInterfaces() {
            for ifname in cfas {
                if let data = CNCopyCurrentNetworkInfo(ifname as! CFString) {
                    let wifidata = data as? Dictionary<String, Any> ?? [String: Any]()
                    let ssid = wifidata["SSID"] as? String
                    print("wifi_info:\(wifidata)")
                    print("ssid:\(ssid ?? "")")
                    
                    self.wifiInfo = wifidata
                    self.ssid = ssid
                }
            }
        }
    }
}
