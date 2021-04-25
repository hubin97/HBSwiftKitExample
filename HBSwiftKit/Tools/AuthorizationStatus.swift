//
//  AuthorizationStatus.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/4/22.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import CoreLocation
import AVFoundation
import Photos
import CoreBluetooth
//iOS9新增蜂窝网络权限授权 CoreTelephony/CTCellularData
import CoreTelephony

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
 <!-- 媒体资料库 -->
 <key>NSAppleMusicUsageDescription</key>
 <string>App需要您的同意,才能访问媒体资料库</string>
 <!-- 语音识别 -->
 <key>NSSpeechRecognitionUsageDescription</key>
 <string>App需要您的同意,才能使用语音识别</string>
 ————————————————
 版权声明：本文为CSDN博主「夕阳下的守望者」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
 原文链接：https://blog.csdn.net/wgl_happy/article/details/53810647
 https://www.jianshu.com/p/0902b2b0b3e3?from=singlemessage
 */
//MARK: - global var and methods
public typealias AuthStatus = AuthorizationStatus
public typealias AuthsBlock = (_ isEnable: Bool) -> Void

//MARK: - main class
/// 权限控制类
public class AuthorizationStatus: NSObject {

    public static let shared = AuthStatus()
    
    /// 跳转到系统设置页
    public func openSettings() {
        guard let setUrl = URL.init(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(setUrl) {
            UIApplication.shared.openURL(setUrl)
        }
    }
    
    /// APNs服务
    public static func apnsServices(authsBlock: @escaping AuthsBlock) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    return authsBlock(true)
                }
                UNUserNotificationCenter.current().requestAuthorization(options: UNAuthorizationOptions.init(rawValue: UNAuthorizationOptions.alert.rawValue | UNAuthorizationOptions.badge.rawValue | UNAuthorizationOptions.sound.rawValue)) { (granted, error) in
                    //print("APNs授权\(granted ? "成功": "失败")")
                    return authsBlock(granted)
                }
            }
        } else {
            // Fallback on earlier versions
            if let notiSettings = UIApplication.shared.currentUserNotificationSettings, notiSettings.types != UIUserNotificationType() {
                return authsBlock(true)
            }
            let notiSettings = UIUserNotificationSettings.init(types: UIUserNotificationType(rawValue: (UIUserNotificationType.alert.rawValue | UIUserNotificationType.sound.rawValue | UIUserNotificationType.badge.rawValue)), categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notiSettings)
            return authsBlock(false)
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
     
     Error: This app has attempted to access privacy-sensitive data without a usage description. The app's Info.plist must contain an “NSLocationWhenInUseUsageDescription” key with a string value explaining to the user how the app uses this data
     */
    public static func locationServices(authsBlock: AuthsBlock) {
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() != .notDetermined {
            return authsBlock(true)
        }
        AuthStatus().startLocation()
        return authsBlock(false)
    }
    
    /// 注意必须要有实例对象后下面3句,不然弹框提示一闪而过; 默认10s移除
    //fileprivate var locationManager = CLLocationManager()
    func startLocation() {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
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
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
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
            PHPhotoLibrary.requestAuthorization { (newStatus) in
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
    
    /// 蓝牙权限
    /**
     <!-- 蓝牙 -->
     <key>NSBluetoothPeripheralUsageDescription</key>
     <string>App需要您的同意,才能访问蓝牙</string>
     */
    public static func bleService(authsBlock: @escaping AuthsBlock) {
        if #available(iOS 13.1, *) {
            let authStatus: CBManagerAuthorization = CBManager.authorization
            if authStatus == .allowedAlways {
                return authsBlock(true)
            }
            AuthStatus.shared.launchBleAlert()
            return authsBlock(false)
        } else {
            // Fallback on earlier versions
            let authStatus: CBPeripheralManagerAuthorizationStatus = CBPeripheralManager.authorizationStatus()
            if authStatus == .authorized {
                return authsBlock(true)
            }
            //AuthStatus.shared.launchBleAlert()
            return authsBlock(false)
        }
    }
    /// 呼出权限提醒弹框(此权限与蓝牙功能开启关闭无关)
    /// 系统蓝牙设备管理对象，可以把他理解为主设备，通过他，可以去扫描和链接外设
    fileprivate lazy var centralManager: CBCentralManager = {
        // CBCentralManagerScanOptionAllowDuplicatesKey值为 No，表示不重复扫描已发现的设备
        let options = [CBCentralManagerOptionShowPowerAlertKey: "YES", CBCentralManagerScanOptionAllowDuplicatesKey: "NO"]
        let centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        return centralManager
    }()
    func launchBleAlert() {
        guard centralManager.state != .poweredOn else { return }
        if centralManager.state == .unsupported {
            print("unsupported ble")
        }
        if let productName = kInfoPlist.value(forKey: "CFBundleName") as? String,
           let message = kInfoPlist.value(forKey: "NSBluetoothPeripheralUsageDescription") as? String {
            let alert = AlertBlockView.init(title: "\"\(productName)\"想要使用蓝牙", message: message)
            alert.addAction("忽略", .cancel, tapAction: nil)
            alert.addAction("去设置") { [weak self] _ in
                self?.openSettings()
            }
            alert.show()
        }
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
    
}

//MARK: - private mothods
extension AuthorizationStatus {
    
}

//MARK: - call backs
extension AuthorizationStatus {
    
}

//MARK: - delegate or data source
extension AuthorizationStatus: CLLocationManagerDelegate {
    /// 辅助弹框提示
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations---")
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError---")
    }
}

extension AuthorizationStatus: CBCentralManagerDelegate {
    /// 辅助弹框提示
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn && central.state != .unsupported {
            print("central.state:\(central.state)")
        }
    }
}


//MARK: - other classes
