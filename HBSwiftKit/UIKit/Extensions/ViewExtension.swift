//
//  ViewExtension.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/8/13.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import CoreImage
import Foundation

//MARK: - global var and methods
public typealias ViewExtension = UIView

//MARK: - main class
extension ViewExtension {
    
    //MARK: 获取当前视图的层级最近控制器
    public func nextVc(view:UIView) -> UIViewController? {
        
        var nextResponder: UIResponder? = self
        repeat {
            nextResponder = nextResponder?.next
            
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            
        } while nextResponder != nil
        
        return nil
    }
    
    //MARK: 指定矩形圆角
    /// 指定矩形某个/多个角为圆角, 默认全圆角
    public func setRectCorner(rectCorner: UIRectCorner = .allCorners, radiiSize: CGFloat) {
        
        // 部分圆角设定 UIRectCorner(rawValue: UIRectCorner.bottomLeft.rawValue | UIRectCorner.bottomRight.rawValue)
        let path: UIBezierPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: radiiSize, height: radiiSize))
        let masklayer: CAShapeLayer = CAShapeLayer()
        masklayer.masksToBounds = true
        masklayer.frame = self.bounds
        masklayer.path = path.cgPath
        self.layer.mask = masklayer
    }
    
    //MARK: 指定矩形渐变色
    /// 指定矩形渐变色 颜色数组及方向
    public enum GradientDirection {
        case lefttoright
        case toptobottom
    }
    public func setGradientColor(colors: [UIColor], direction: GradientDirection){
        for item in self.layer.sublayers ?? []  where item is CAGradientLayer {
            item.removeFromSuperlayer()
        }
        let gradient = CAGradientLayer.init()
        gradient.frame = self.bounds
        gradient.colors = colors.map({ $0.cgColor })
        gradient.startPoint = CGPoint(x: 0, y: 0)
        
        if direction == .lefttoright {
            gradient.endPoint = CGPoint(x: 1, y: 0)
        } else if direction == .toptobottom {
            gradient.endPoint = CGPoint(x: 0, y: 1)
        }
        self.layer.insertSublayer(gradient, at: 0)
    }

    //MARK: 视图截取
    // 区别系统视图截取 "let view = item.snapshotView(afterScreenUpdates: true)"
    public func interceptView() -> UIImage? {
        
        let scale:CGFloat = UIScreen.main.scale   // 设置屏幕倍率可以保证截图的质量
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, true, scale)
        //self.layer.render(in: UIGraphicsGetCurrentContext()!)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 截图视图中的一部分
    public func interceptRangeView(atFrame: CGRect?) -> UIImage? {
        
        guard let rect = atFrame else { return nil }

        let inputImage = interceptView()
        
        let scale = UIScreen.main.scale   // 设置屏幕倍率可以保证截图的质量
        let real_rect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        
        guard let cutImageRef: CGImage = inputImage?.cgImage?.cropping(to: real_rect) else {
            return nil
        }

        return UIImage(cgImage: cutImageRef)
    }


    //MARK: 高斯模糊
    //https://www.cnblogs.com/kenshincui/p/12181735.html
    //https://www.jianshu.com/p/341a06dd0b46
    @discardableResult
    public func addBlur(style: UIBlurEffect.Style = .dark, alpha: CGFloat = 0.7) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurBackground = UIVisualEffectView(effect: blurEffect)
        blurBackground.frame = self.bounds
        addSubview(blurBackground)
        blurBackground.alpha = alpha
        return blurBackground
    }
    
    // UIToolBar  自定义样式太少
    // UIVisualEffectView  模糊效果不好
    public func addImageBlur(style: UIBlurEffect.Style = .dark, alpha: CGFloat = 0.7, img: UIImage?) {
        
        let imageView = UIImageView.init(image: img)
        imageView.frame = self.bounds;
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: style))
        blurBackground.frame = self.bounds
        blurBackground.alpha = alpha
        imageView.addSubview(blurBackground)
    }
    
    /// CIFilter  最终方案
    public func addImageBlur2(style: UIBlurEffect.Style = .dark, alpha: CGFloat = 1, img: UIImage?) {
        
        if let image = ciFilter(img) {
            let imageView = UIImageView.init(image: image)
            imageView.frame = self.bounds;
            imageView.contentMode = .scaleAspectFit
            addSubview(imageView)
        }
    }
    
    // UIImage+ImageEffects  // 此方法色值有问题
//    func addImageBlur3(style: UIBlurEffect.Style = .dark, alpha: CGFloat = 0.7, img: UIImage?) {
//
//        let image = img?.applyBlur(withRadius: 2, tintColor: UIColor.init(white: 0, alpha: alpha), saturationDeltaFactor: 0, maskImage: nil)
//        let imageView = UIImageView.init(image: image)
//        imageView.frame = self.bounds;
//        imageView.contentMode = .scaleAspectFit
//        addSubview(imageView)
//    }
    
    // CoreImage
    //https://www.shuzhiduo.com/A/QV5Z60O75y/
    public func ciFilter(_ image: UIImage?) -> UIImage? {
        
        guard let img = image, let cgImage = img.cgImage else {
            return nil
        }
        
        let input_ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputImageKey: input_ciImage])
        //设置模糊程度
        //filter?.setValue(5, forKey: "inputRadius")
        
        let outputImage = filter?.outputImage

        let context = CIContext.init(options: nil)
        // 尺寸大小问题处理
        let cgimg = context.createCGImage(outputImage!, from: input_ciImage.extent)
        let output_Image = UIImage.init(cgImage: cgimg!, scale: img.scale, orientation: img.imageOrientation)
        return output_Image
    }
}
