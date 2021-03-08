//
//  Extension+Image.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/8/30.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation

//MARK: - global var and methods
public typealias Extension_Image = UIImage

//MARK: - main class
extension Extension_Image {

    /// 水平翻转（即左右镜像）
    /// - Returns: 新Image对象
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
    
    /// 垂直翻转
    /// - Returns: 新Image对象
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
    
    /// 根据颜色生成图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 尺寸
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: CGPoint.zero, size: size))
        context?.setShouldAntialias(true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        guard let cgImage = image?.cgImage else {
            self.init()
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    /// 质量压缩 (2分压缩5次)
    /// 注意 data.count长度判断可能与实际文件占用内存有差异
    public func compress(maxSize: Int) -> Data? {
        var compression: CGFloat = 1
        guard var data = self.jpegData(compressionQuality: 1) else { return nil }
        if data.count < maxSize {
            return data
        }
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = self.jpegData(compressionQuality: compression)!
            if CGFloat(data.count) < CGFloat(maxSize){
                min = compression
            } else if data.count > maxSize {
                max = compression
            } else {
                break
            }
        }
        return data
    }
    
    /// 尺寸压缩
    /// 如果使用更精准的方案, 可参考 鲁班压缩算法 https://github.com/Curzibn/Luban/blob/master/DESCRIPTION.md
    public func compress(maxLength: CGFloat) -> UIImage? {
        if maxLength <= 0 {
            return self
        }
        var imgMax:CGFloat = 0
        if self.size.width/self.size.height >= 1 {
            imgMax = self.size.width
        } else {
            imgMax = self.size.height
        }
        if imgMax > maxLength {
            let ratio = maxLength/imgMax
            let newW  = self.size.width * ratio
            let newH  = self.size.height * ratio
            
            let newSize = CGSize(width: newW, height: newH)
            UIGraphicsBeginImageContext(newSize)
            self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            guard let _img = img else { return  nil}
            return _img
        } else {
            return self
        }
    }
    
    /// TODO: Luban

}

//MARK: - private mothods
class AssetsClass { }
extension Extension_Image {
    
    /// 获取bundle资源
    public static func bundleImage(named: String) -> UIImage? {
        let bundlePath = "\(Bundle(for: AssetsClass.self).bundlePath)" + "/HBSwiftKit.bundle"
        let bundle = Bundle(path: bundlePath)
        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }
}
