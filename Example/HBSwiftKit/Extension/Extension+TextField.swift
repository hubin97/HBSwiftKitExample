//
//  Extension_TextField.swift
//  LuteBase
//
//  Created by hubin.h on 2023/12/26.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

#warning("注意此扩展仅能放在当前项目下, 放在其他外部组件库中会报错 `Ambiguous use of 'placeholder'`, 编译器会混淆 ")
// MARK: - global var and methods
private typealias Extension_TextField = UITextField

//private var placeholderKey = "placeholderKey"

//private struct AssociatedKeys {
//    static var placeholderKey = "placeholderKey"
//}

// FIXME: 使用此方式无警告
private struct AssociatedKeys {
    static var placeholderKey = UnsafeRawPointer(bitPattern: "placeholderKey".hashValue)!
}

// MARK: - main class
extension Extension_TextField: AssociatedObjectStore {
    
    // 重写系统属性, 进行属性监听
    public var placeholder: String? {
        get {
            return associatedObject(forKey: &AssociatedKeys.placeholderKey)
            //return objc_getAssociatedObject(self, &UITextField.placeholderKey) as? String
        }
        set(newValue) {
            //objc_setAssociatedObject(self, &UITextField.placeholderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setAssociatedObject(newValue, forKey: &AssociatedKeys.placeholderKey)
            
            // 当placeholder属性被设置时执行的逻辑
            let attrs = NSMutableAttributedString(string: newValue ?? "")
            attrs.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: attrs.allRange)
            self.attributedPlaceholder = attrs
        }
    }
}

//extension Extension_TextField {
//    
//    private static var placeholderKey = "placeholderKey"
//    private static var placeholderColorKey = "placeholderColorKey"
//    
//    public var placeholderColor: UIColor? {
//        get {
//            return objc_getAssociatedObject(self, &UITextField.placeholderColorKey) as? UIColor
//        }
//        set {
//            objc_setAssociatedObject(self, &UITextField.placeholderColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            
//            // 当placeholder属性被设置时执行的逻辑
//            if let tplaceholder = placeholder {
//                let attrs = NSMutableAttributedString(string: tplaceholder)
//                attrs.addAttribute(NSAttributedString.Key.foregroundColor, value: newValue ?? .lightGray, range: attrs.allRange)
//                self.attributedPlaceholder = attrs
//            }
//        }
//    }
//    
//    // 属性监听
//    public var placeholder: String? {
//        get {
//            return objc_getAssociatedObject(self, &UITextField.placeholderKey) as? String
//        }
//        set(newValue) {
//            objc_setAssociatedObject(self, &UITextField.placeholderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            
//            // 当placeholder属性被设置时执行的逻辑
//            let attrs = NSMutableAttributedString(string: newValue ?? "")
//            attrs.addAttribute(NSAttributedString.Key.foregroundColor, value: placeholderColor ?? .lightGray, range: attrs.allRange)
//            self.attributedPlaceholder = attrs
//        }
//    }
//    
//    // kvo 监听不了系统 placeholder
//}
