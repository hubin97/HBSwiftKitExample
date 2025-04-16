//
//  AuthorizationStatus.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/4/22.
//  Copyright © 2020 Wingto. All rights reserved.

import UIKit
import Foundation
import CoreLocation
import AVFoundation
import Photos
import CoreBluetooth
//iOS9新增蜂窝网络权限授权 CoreTelephony/CTCellularData
import CoreTelephony
import Intents
import EventKit

/**
 <!-- 相册 -->
 <key>NSPhotoLibraryUsageDescription</key>
 <string>App需要您的同意,才能访问相册</string>
 <!-- 相机 -->
 <key>NSCameraUsageDescription</key>
 <string>App需要您的同意,才能访问相机</string>
 <!-- 麦克风 -->
 <key>NSMicrophoneUsageDescription</key>
 <string>App需要您的同意,才能访问麦克风</string>
 <!-- 位置 -->
 <key>NSLocationUsageDescription</key>
 <string>App需要您的同意,才能访问位置</string>
 <!-- 在使用期间访问位置 -->
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>App需要您的同意,才能在使用期间访问位置</string>
 <!-- 始终访问位置 -->
 <key>NSLocationAlwaysUsageDescription</key>
 <string>App需要您的同意,才能始终访问位置</string>
 <!-- 日历 -->
 <key>NSCalendarsUsageDescription</key>
 <string>App需要您的同意,才能访问日历</string>
 <!-- 提醒事项 -->
 <key>NSRemindersUsageDescription</key>
 <string>App需要您的同意,才能访问提醒事项</string>
 <!-- 运动与健身 -->
 <key>NSMotionUsageDescription</key>
  <string>App需要您的同意,才能访问运动与健身</string>
 <!-- 健康更新 -->
 <key>NSHealthUpdateUsageDescription</key>
 <string>App需要您的同意,才能访问健康更新 </string>
 <!-- 健康分享 -->
 <key>NSHealthShareUsageDescription</key>
 <string>App需要您的同意,才能访问健康分享</string>
 <!-- 蓝牙 -->
 <key>NSBluetoothPeripheralUsageDescription</key>
 <string>App需要您的同意,才能访问蓝牙</string>
 <key>NSBluetoothAlwaysUsageDescription</key>
 <string>App需要您的同意,才能访问蓝牙</string>
 <!-- 媒体资料库 -->
 <key>NSAppleMusicUsageDescription</key>
 <string>App需要您的同意,才能访问媒体资料库</string>
 <!-- 语音识别 -->
 <key>NSSpeechRecognitionUsageDescription</key>
 <string>App需要您的同意,才能使用语音识别</string>
 <key>NSSiriUsageDescription</key>
 <string>App需要您的同意,才能使用Siri</string>
 

 Privacy - Calendars Usage Description
 App需要您的同意,才能访问你的日历
 Privacy - Reminders Usage Description
 App需要您的同意,才能访问你的提醒事项
 ————————————————
 版权声明：本文为CSDN博主「夕阳下的守望者」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
 原文链接：https://blog.csdn.net/wgl_happy/article/details/53810647
 https://www.jianshu.com/p/0902b2b0b3e3?from=singlemessage
 */
// MARK: - global var and methods
// !!!: 务必考虑回调内容是否需要主线程处理
public typealias AuthStatus = AuthorizationStatus
public typealias AuthsBlock = (_ granted: Bool?) -> Void

/// 唤起定位权限弹框
public protocol AuthStatusLocationDelegate: AnyObject {
    //FIXME: 注意locManager必须由外部全局持有, 否则弹框会一闪而过, 无法交互点击
    var locManager: CLLocationManager { get set }
    func wakeupAuthAlert()
}

extension AuthStatusLocationDelegate {
    public func wakeupAuthAlert() {
        locManager.requestAlwaysAuthorization()
        locManager.requestWhenInUseAuthorization()
    }
}

/// 权限控制类
public class AuthorizationStatus: NSObject {

    public static let shared = AuthStatus()
    
    override init() {
        super.init()
        // 调用self.centralManager，触发初始化
        _ = self.centralManager
    }
        
    /// 获取系统蓝牙状态回调,
    var systemBTStateBlock: ((_ state: CBManagerState) -> Void)?
    /// 系统蓝牙设备管理对象
    lazy var centralManager: CBCentralManager = {
        // CBCentralManagerScanOptionAllowDuplicatesKey值为 No，表示不重复扫描已发现的设备
        let options = [CBCentralManagerOptionShowPowerAlertKey: "YES", CBCentralManagerScanOptionAllowDuplicatesKey: "NO"]
        let centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        return centralManager
    }()
    
    /// 跳转到系统设置页
    public func openSettings() {
        guard let setUrl = URL.init(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(setUrl) {
            UIApplication.shared.open(setUrl)
        }
    }
    
    /// APNs服务
    public static func apnsServices(authsBlock: @escaping AuthsBlock) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                return authsBlock(true)
            }
            UNUserNotificationCenter.current().requestAuthorization(options: UNAuthorizationOptions(rawValue: UNAuthorizationOptions.alert.rawValue | UNAuthorizationOptions.badge.rawValue | UNAuthorizationOptions.sound.rawValue)) { (granted, _) in
                //print("APNs授权\(granted ? "成功": "失败")")
                return authsBlock(granted)
            }
        }
    }
    
    /// 定位服务
    /**
     <!-- 位置 -->
     <key>NSLocationUsageDescription</key>
     <string>App需要您的同意,才能访问位置</string>
     <!-- 在使用期间访问位置 -->
     <key>NSLocationWhenInUseUsageDescription</key>
     <string>App需要您的同意,才能在使用期间访问位置</string>
     <!-- 始终访问位置 -->
     <key>NSLocationAlwaysUsageDescription</key>
     <string>App需要您的同意,才能始终访问位置</string>
  
     KEY: NSLocationAlwaysAndWhenInUseUsageDescription
     
     This app has attempted to access privacy-sensitive data without a usage description. The app's Info.plist must contain both “NSLocationAlwaysAndWhenInUseUsageDescription” and “NSLocationWhenInUseUsageDescription” keys with string values explaining to the user how the app uses this data
     
     */
    /// 返回 nil, 表示未选定, 
    public static func locationServices(authsBlock: AuthsBlock) {
        let authState = CLLocationManager.authorizationStatus()
        if CLLocationManager.locationServicesEnabled() {
            if authState != .notDetermined {
                return authsBlock((authState == .authorizedAlways || authState == .authorizedWhenInUse) ? true: false)
            } else {
                //AuthStatus().startLocation()
                return authsBlock(nil)
            }
        } else {
            return authsBlock(false)
        }
    }
    
    /// 相机权限
    /**
     <!-- 相机 -->
     <key>NSCameraUsageDescription</key>
     <string>App需要您的同意,才能访问相机</string>
     */
    public static func cameraService(authsBlock: @escaping AuthsBlock) {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .authorized {
            return authsBlock(true)
        } else if authStatus == .notDetermined {
            return AVCaptureDevice.requestAccess(for: .video) { (granted) in
                return authsBlock(granted)
            }
        }
        // .denied, .restricted: unknow
        return authsBlock(false)
    }
    
    /// 相册权限
    /**
     <!-- 相册 -->
     <key>NSPhotoLibraryUsageDescription</key>
     <string>App需要您的同意,才能访问相册</string>
     <!-- iOS11 新增 -->
     <key>NSPhotoLibraryAddUsageDescription</key>
     <string>App需要您的同意,才能添加照片到相册</string>
     */
    public static func albumService(authsBlock: @escaping AuthsBlock) {
        let authStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .authorized {
            return authsBlock(true)
        } else if authStatus == .notDetermined {
            return PHPhotoLibrary.requestAuthorization { (newStatus) in
                return authsBlock(newStatus == .authorized)
            }
        }
        // .denied, .restricted: unknow
        return authsBlock(false)
    }
    
    /// 麦克风权限
    /**
     <!-- 麦克风 -->
     <key>NSMicrophoneUsageDescription</key>
     <string>App需要您的同意,才能访问麦克风</string>
     */
    public static func microphoneService(authsBlock: @escaping AuthsBlock) {
        let authStatus: AVAudioSession.RecordPermission = AVAudioSession.sharedInstance().recordPermission
        if authStatus == .granted {
            return authsBlock(true)
        } else if authStatus == .undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                return authsBlock(granted)
            }
        }
        return authsBlock(false)
    }
    
    /// 应用内使用数据权限, 蜂窝/WLAN网络对应CTCellularData值如下
    /// [关闭:.restricted; WLAN:.restricted; WLAN与蜂窝网络:.notRestricted]
    public static func cellularDataService(authsBlock: @escaping AuthsBlock) {
        CTCellularData().cellularDataRestrictionDidUpdateNotifier = { (CTCellularDataRestrictedState) in
            authsBlock(CTCellularDataRestrictedState == .notRestricted)
        }
    }
    
    /// 获取网络是否可到达
    public static func networkService(authsBlock: @escaping AuthsBlock) {
        let reachability = AlamofireReachability()
        reachability?.startListening()
        reachability?.listener = { status in
            print("network:\(status)")
            authsBlock(status != .notReachable && status != .unknown)
        }
    }
    
    /// 获取Siri是否已开启
    public static func siriService(authsBlock: @escaping AuthsBlock) {
        let siriAuthStatus = INPreferences.siriAuthorizationStatus()
        if siriAuthStatus == .authorized {
            authsBlock(true)
        } else {
            INPreferences.requestSiriAuthorization { st in
                authsBlock(st == .authorized)
            }
        }
    }
    
    //    Privacy - Calendars Usage Description
    //    App需要您的同意,才能访问你的日历
    public static func calendarService(authsBlock: @escaping AuthsBlock) {
        // let auth = EKEventStore.authorizationStatus(for: .event)
        return EKEventStore().requestAccess(to: .event) { granted, _ in
            return authsBlock(granted)
        }
    }
    
    //    Privacy - Reminders Usage Description
    //    App需要您的同意,才能访问你的提醒事项
    public static func reminderService(authsBlock: @escaping AuthsBlock) {
        return EKEventStore().requestAccess(to: .reminder) { granted, _ in
            return authsBlock(granted)
        }
    }
}

// MARK: - private mothods
extension AuthorizationStatus {
    
}

// MARK: - call backs
extension AuthorizationStatus {
    
}

// MARK: - delegate or data source
//extension AuthorizationStatus: AuthStatusLocationDelegate {
//    /// 辅助弹框提示
//    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("didUpdateLocations---")
//    }
//    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("didFailWithError---")
//    }
//}

/// 蓝牙权限
/**
 <!-- 蓝牙 -->
 <key>NSBluetoothPeripheralUsageDescription</key>
 <string>App需要您的同意,才能访问蓝牙</string>
 <!-- 上面权限 官方 API提示iOS13已废弃 -->
 <key>NSBluetoothAlwaysUsageDescription</key>
 <string>App需要您的同意,才能访问蓝牙</string>
 */
// MARK: - 蓝牙权限
/// 手机系统蓝牙是否打开校验
extension AuthorizationStatus: CBCentralManagerDelegate {
    
    /// CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //SVProgressHUD.dismiss()
        systemBTStateBlock?(central.state)
    }
    
    /// 获取系统蓝牙是否打开
    /// 代理方式获取
    /// - Parameter authsBlock: 异步返回状态
    public static func systemBleStateUpdate(authsBlock: @escaping ((_ state: CBManagerState) -> Void)) {
        let central = AuthStatus.shared.centralManager
        if central.state != .unknown {
            authsBlock(central.state)
            return
        }
        AuthStatus.shared.systemBTStateBlock = authsBlock
    }
    
    /// 使用此方法, 后续直接取AuthStatus.shared.centralManager.state去判断
    /// - Parameter showHUD:
//    public static func systemBleStateUpdate(_ showHUD: Bool = false) {
//        let central = AuthStatus.shared.centralManager
//        if showHUD && central.state == .unknown {
//            ProgressHUD.show(withStatus: "请稍后...")
//        }
//    }
    
    //!!!: 必要时 使用 systemBleState 方法 可全替代
    //!!!: 此方法只能判断当前应用内是否授权, 打开蓝牙服务, 需要进一步判断手机是否打开蓝牙(此时必须使用代理方式获取)
    public static func bleService(authsBlock: @escaping AuthsBlock) {
        if #available(iOS 13.1, *) {
            let authStatus = CBManager.authorization
            if authStatus == .allowedAlways {
                return authsBlock(true)
            }
            return authsBlock(false)
        } else {
            let authStatus = CBPeripheralManager.authorizationStatus()
            if authStatus == .authorized {
                return authsBlock(true)
            }
            return authsBlock(false)
        }
    }
}

// MARK: - other Utils
