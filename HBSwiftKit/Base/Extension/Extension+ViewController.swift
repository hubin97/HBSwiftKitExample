//
//  Extension+ViewController.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2022/5/31.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit

// MARK: - global var and methods
private typealias Extension_ViewController = UIViewController

// MARK: - main class
extension Extension_ViewController {
    
    struct VcKeys {
        static var keyboardShow = UnsafeRawPointer(bitPattern: "keyboardShow".hashValue)
        static var keyboardHide = UnsafeRawPointer(bitPattern: "keyboardHide".hashValue)
    }
    
    var keyboardShowBlock: ((Notification) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &VcKeys.keyboardShow) as? ((Notification) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &VcKeys.keyboardShow, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    var keyboardHideBlock: ((Notification) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &VcKeys.keyboardHide) as? ((Notification) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &VcKeys.keyboardHide, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
}

// MARK: - call backs
extension Extension_ViewController {
    
    public func addKeyboardListener(willShow: ((Notification) -> Void)? = nil, willHide: ((Notification) -> Void)? = nil) {
        self.keyboardShowBlock = willShow
        self.keyboardHideBlock = willHide
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public func removeKeyboardListener() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        self.keyboardShowBlock?(notification)
    }
    
    @objc func keyBoardWillHide(notification: Notification) {
        self.keyboardHideBlock?(notification)
    }
}
