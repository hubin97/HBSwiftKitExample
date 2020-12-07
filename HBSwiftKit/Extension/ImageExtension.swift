//
//  ImageExtension.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/8/30.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation

//MARK: - global var and methods
public typealias ImageExtension = UIImage

//MARK: - main class
extension ImageExtension {

    // 水平翻转（即左右镜像）
    public func horizontalFlip() -> UIImage {
     
        //翻转图片的方向
        let flipImageOrientation = (self.imageOrientation.rawValue + 4) % 8
        //翻转图片
        let flipImage =  UIImage(cgImage: self.cgImage!,
            scale:self.scale,
            orientation:UIImage.Orientation(rawValue: flipImageOrientation)!
        )
        return flipImage
    }
    
    // 垂直翻转
    public func verticalFlip() -> UIImage {
        
        //翻转图片的方向
        var flipImageOrientation = (self.imageOrientation.rawValue + 4) % 8
        flipImageOrientation += flipImageOrientation%2==0 ? 1 : -1
        
        //翻转图片
        let flipImage =  UIImage(cgImage:self.cgImage!,
                                 scale:self.scale,
                                 orientation:UIImage.Orientation(rawValue: flipImageOrientation)!
        )
        return flipImage
    }
    
    /// 获取bundle资源
    public static func bundleImage(named: String) -> UIImage? {
        let bundlePath = "\(Bundle(for: HBSwiftKitManager.self).bundlePath)" + "/HBSwiftKit.bundle"
        let bundle = Bundle(path: bundlePath)
        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }
}