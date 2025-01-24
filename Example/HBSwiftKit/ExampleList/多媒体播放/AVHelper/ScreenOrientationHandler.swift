//
//  ScreenOrientationHandler.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2025/1/20.

import Foundation
import UIKit

// MARK: - global var and methods

private struct AssociatedKeys {
    static var currentOrientation = UnsafeRawPointer(bitPattern: "currentOrientation".hashValue)
    static var isOrientationLocked = UnsafeRawPointer(bitPattern: "isOrientationLocked".hashValue)
}

// MARK: - main class
protocol ScreenOrientationHandler where Self: UIViewController {
    
    /// 当前方向
    var currentOrientation: UIInterfaceOrientation { get set }
    /// 是否锁定方向
    var isOrientationLocked: Bool { get set }
    /// 是否全屏
    var isFullScreen: Bool { get set }
    
    /// 初始化方向监听
    func setupOrientationListener()
    /// 处理设备方向变化
    func handleDeviceOrientationChange()
    /// 强制切换屏幕方向
    func updateOrientation(to orientation: UIInterfaceOrientation)
    /// 更新布局
    func adjustLayout(for orientation: UIInterfaceOrientation)
    func adjustLayoutForIsFullScreen()
    
    /// 更新状态栏显示
    func updateStatusBarAppearance()
}

// MARK: - private mothods
extension ScreenOrientationHandler {

//    var currentOrientation: UIInterfaceOrientation {
//        get {
//            let oRawValue = objc_getAssociatedObject(self, &AssociatedKeys.currentOrientation) as? UIInterfaceOrientation.RawValue ?? UIInterfaceOrientation.portrait.rawValue
//            return UIInterfaceOrientation(rawValue: oRawValue) ?? UIInterfaceOrientation.portrait
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.currentOrientation, newValue, .OBJC_ASSOCIATION_ASSIGN)
//        }
//    }
//    
//    var isOrientationLocked: Bool {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.isOrientationLocked) as? Bool ?? false
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.isOrientationLocked, newValue, .OBJC_ASSOCIATION_ASSIGN)
//        }
//    }
    
    func toggleLockOrientation() {
        isOrientationLocked.toggle()
    }

    func toggleOrientation() {
        let targetOrientation: UIInterfaceOrientation = currentOrientation.isLandscape ? .portrait : .landscapeRight
        updateOrientation(to: targetOrientation)
    }
    
    //
    func setupOrientationListener() {
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self, !self.isOrientationLocked else { return }
            self.handleDeviceOrientationChange()
        }
    }
    
    func handleDeviceOrientationChange() {
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .landscapeLeft:
            updateOrientation(to: .landscapeLeft)
        case .landscapeRight:
            updateOrientation(to: .landscapeRight)
        case .portrait:
            updateOrientation(to: .portrait)
        default:
            break
        }
    }
    
    func updateOrientation(to orientation: UIInterfaceOrientation) {
        guard currentOrientation != orientation else { return }
        currentOrientation = orientation
        
        // 强制更新方向
        orientationRotate(orientation.isLandscape)
        //UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        //UIViewController.attemptRotationToDeviceOrientation()
        
        // 调整布局和状态栏
        adjustLayout(for: orientation)
        updateStatusBarAppearance()
    }
    
    func orientationRotate(_ open: Bool) {
        if #available(iOS 16, *) {
            guard let windowScene = self.view.window?.windowScene else {
                print("WindowScene 不存在，无法切换方向")
                return
            }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: open ? .landscapeRight : .portrait)) { error in
                    print("请求失败: \(error.localizedDescription)")
//                    self.vm?.isFullScreen = false
//                    self.naviBar.isHidden = false
//                    self.controlView.isHidden = false
            }
        } else {
            let orientation = open ? UIInterfaceOrientation.landscapeRight : UIInterfaceOrientation.portrait
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
            self.setNeedsStatusBarAppearanceUpdate()
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    func adjustLayout(for orientation: UIInterfaceOrientation) {
        // 默认实现为空，具体调整交由遵循者实现
    }
    
    func adjustLayoutForIsFullScreen() {
        
    }
    
    func updateStatusBarAppearance() {
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - call backs
extension ScreenOrientationHandler { 
}

// MARK: - delegate or data source
extension ScreenOrientationHandler { 
}

// MARK: - other classes
