//
//  Extension+Image.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/8/30.
//  Copyright © 2020 WingTo. All rights reserved.

//单元测试 ✅
import UIKit
import Foundation

//MARK: - global var and methods
fileprivate typealias Extension_Image = UIImage

//MARK: - main class
extension Extension_Image {
    
    /// 颜色重绘成图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 尺寸
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) {
        if size.width <= 0 || size.height <= 0 { return nil }
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: CGPoint.zero, size: size))
        context?.setShouldAntialias(true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    /// 以base64字符串初始化
    /// - Parameter base64String: base64字符串
    /// - Returns: 图片对象
    public func imageWithBase64(_ base64String: String) -> UIImage? {
        if base64String.isEmpty { return nil }
        guard let data = Data.init(base64Encoded: base64String) else { return nil }
        return UIImage.init(data: data)
    }
    
    /// 转成base64String, 默认png
    /// - Returns: base64字符串
    public func toBase64String() -> String? {
        let data = self.pngData()
        return data?.base64EncodedString()
    }
    
    
   
}

extension Extension_Image {

//    /// 是否有alpha通道
//    func hasAlphaChannel() -> Bool {
//        guard let cgImage = self.cgImage else { return false }
//        let alpha: CGImageAlphaInfo = cgImage.alphaInfo //& CGBitmapInfo.alphaInfoMask
//        return alpha == CGImageAlphaInfo.first || alpha == CGImageAlphaInfo.last || alpha == CGImageAlphaInfo.premultipliedFirst || alpha == CGImageAlphaInfo.premultipliedLast
//    }
    
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

    /// 获取位置处颜色
    public func pixelColor(pos: CGPoint) -> UIColor? {
        let pixelData = self.cgImage?.dataProvider?.data
        guard pixelData != nil else { return nil }
        let data:UnsafePointer<UInt8> =  CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        print(r, g, b, a)
        let corlor = UIColor.init(red: r, green: g, blue: b, alpha: a)
        return corlor
    }
    
    ///MARK: 人脸检测, 识别人脸数统计
    /// 若处理人脸截图居中, 使用 #pod 'FaceAware'
    /// - Returns: 人脸数
    public func foundFaces() -> Int? {
        guard let ciImage = CIImage(image: self) else { return nil }
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
        if let features = detector?.features(in: ciImage), features.count > 0 {
            //print("found \(features.count) faces")
            return features.count
        }
        return nil
    }
    
    public static func systemShare(activityItems: [UIImage], excludedTypes: [UIActivity.ActivityType]? = nil, completeHandle:((_ isFinish: Bool) -> Void)? = nil) {
        let activityVc = UIActivityViewController.init(activityItems: activityItems as [Any], applicationActivities: nil)
        if let excludedTypes = excludedTypes {
            //activityVc.excludedActivityTypes = [.postToFacebook, .postToTwitter, .postToWeibo, .message, .mail, .print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .airDrop, .openInIBooks]
            activityVc.excludedActivityTypes = excludedTypes
        }
        stackTopViewController()?.present(activityVc, animated: true, completion: nil)
        activityVc.completionWithItemsHandler = {(activityType, completed, items, error) -> Void in
            if completed == true {
                print("分享成功")
                completeHandle?(true)
            }
            // 不能少
            activityVc.completionWithItemsHandler = nil
        }
    }
}

//MARK: - 图片压缩处理
extension Extension_Image {
    
    /// 质量压缩 (2分压缩5次)
    /// 注意 data.count长度判断可能与实际文件占用内存有差异
    /// - Parameter maxBytes: 指定bytes
    /// - Returns: 压缩后图片数据
    public func compress(maxBytes: Int) -> Data? {
        var compression: CGFloat = 1
        guard var data = self.jpegData(compressionQuality: 0.9) else { return nil }
        if data.count < maxBytes {
            return data
        }
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = self.jpegData(compressionQuality: compression)!
            if CGFloat(data.count) < CGFloat(maxBytes){
                min = compression
            } else if data.count > maxBytes {
                max = compression
            } else {
                break
            }
        }
        return data
    }
    
    /// 尺寸压缩
    /// - Parameter maxpt: 取最长的边, 跟最大像素点(@2x, pt; 如120*120即maxpt为60)比例调整
    /// - Returns: 调整处理后结果
    public func resize(maxpt: CGFloat) -> UIImage? {
        // 给定尺寸有问题, 不处理
        if maxpt <= 0 { return self }
        // 满足要求不处理
        var imgMax = self.size.width > self.size.height ? self.size.width: self.size.height
        if imgMax <= maxpt { return self }
        // 调整到指定大小
        while imgMax > maxpt {
            let ratio = maxpt/imgMax
            let newW  = self.size.width * ratio
            let newH  = self.size.height * ratio
            let newSize = CGSize(width: newW, height: newH)
            UIGraphicsBeginImageContext(newSize)
            self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            imgMax = newW > newH ? newW: newH
            return img
        }
        return self
    }
    
    /// TODO: Luban
    /// 如果使用更精准的方案, 可参考 鲁班压缩算法 https://github.com/Curzibn/Luban/blob/master/DESCRIPTION.md

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
    
//    //对Extension_Data -> ImageType 补充
//    // 参考YYKit->YYImage/NSBundle+YYAdd.h
//    func preferredScales() -> [Int] {
//        let screenScale = UIScreen.main.scale
//        var scales = [3, 2, 1]
//        if (screenScale <= 1) {
//            scales = [1, 2, 3]
//        } else if (screenScale <= 2) {
//            scales = [2, 3, 1]
//        }
//        return scales
//    }
//
//    /**
//     https://blog.csdn.net/weixin_34268843/article/details/87977961?utm_medium=distribute.pc_relevant.none-task-blog-baidujs_title-0&spm=1001.2101.3001.4242
//     var count: UInt32 = 0
//     let ivars = class_copyIvarList(UIImageAsset.self, &count)!
//     for i in 0..<count {
//         let namePoint = ivar_getName(ivars[Int(i)])!
//         let name = String(cString: namePoint)
//         print(name)
//     }
//     */
//    public func imageExtensionName() -> String? {
//        // If no extension, guess by system supported (same as UIImage). -> png
//        guard let imageAsset = self.imageAsset, let imgName = imageAsset.value(forKeyPath: "_assetName") as? String else { return nil }
//        let res = NSString(string: imgName)
//        let name = res.deletingPathExtension
//        let ext = res.pathExtension
//        let exts = ext.isEmpty == false ? [ext] : ["", "png", "jpeg", "jpg", "gif", "webp", "apng"]
//        let scales = self.preferredScales()
//        for scale in scales {
//            let scaledName = name + ((scale > 1) ? "@\(scale)x": "")
//            for e in exts {
//                if let path = Bundle.main.path(forResource: scaledName, ofType: e), path.isEmpty == false {
//                    return e
//                }
//            }
//        }
//        return nil
//    }
}
