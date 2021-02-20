//
//  View+Extension.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/8/13.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import CoreImage
import Foundation

//MARK: - global var and methods
public typealias View_Extension = UIView

//MARK: - main class
extension View_Extension {
    
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
    /// - Parameters:
    ///   - rectCorner: 圆角位置
    ///   - radiiSize: 弧度
    public func setRectCorner(rectCorner: UIRectCorner = .allCorners, radiiSize: CGFloat) {
        
        // 部分圆角设定 UIRectCorner(rawValue: UIRectCorner.bottomLeft.rawValue | UIRectCorner.bottomRight.rawValue)
        let path: UIBezierPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: radiiSize, height: radiiSize))
        let masklayer: CAShapeLayer = CAShapeLayer()
        masklayer.masksToBounds = true
        masklayer.frame = self.bounds
        masklayer.path = path.cgPath
        self.layer.mask = masklayer
    }
    
    //MARK: 指定视图圆角边框属性
    /// 设置视图的圆角边框属性
    /// - Parameters:
    ///   - borderColor: 边框颜色
    ///   - borderWidth: 边框宽
    ///   - raddi: 弧度
    ///   - corners: 圆角位置
    ///   - isDotted: 是否虚线边框
    ///   - lineDashPattern: 虚线间隔
    public func setRoundCorners(borderColor: UIColor = .black,
                                borderWidth: CGFloat = 1.0,
                                raddi: CGFloat = 4.0,
                                corners: UIRectCorner = .allCorners,
                                isDotted: Bool = false,
                                lineDashPattern: [NSNumber] = [NSNumber(value: 4), NSNumber(value: 2)]) {
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: raddi, height: raddi))
        // 圆角
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
        
        // 边框
        let borderLayer = CAShapeLayer()
        borderLayer.frame = bounds
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = borderWidth
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        if isDotted {
            borderLayer.lineDashPattern = lineDashPattern
        }
        layer.addSublayer(borderLayer)
    }


    //MARK: 指定矩形渐变色
    /// 指定矩形渐变色 颜色数组及方向
    public enum GradientDirection {
        case lefttoright
        case toptobottom
    }
    
    /// 设置视图颜色渐变
    /// - Parameters:
    ///   - colors: 颜色数组
    ///   - direction: 渐变方向
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
        // 设置屏幕倍率可以保证截图的质量
        let scale:CGFloat = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.frame.size, true, scale)
        //self.layer.render(in: UIGraphicsGetCurrentContext()!)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // 将当前视图转为UIImage
    @available(iOS 10.0, *)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
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

// MARK: - view + BlurView
// 待验证
extension View_Extension {
    
    private struct BlurAssociatedKeys {
        static var descriptiveName = "AssociatedKeys.DescriptiveName.blurView"
    }
    
    private (set) var blur: BlurView {
        get {
            if let blurView = objc_getAssociatedObject(
                self,
                &BlurAssociatedKeys.descriptiveName
            ) as? BlurView {
                return blurView
            }
            self.blur = BlurView(to: self)
            return self.blur
        }
        set(blurView) {
            objc_setAssociatedObject(
                self,
                &BlurAssociatedKeys.descriptiveName,
                blurView,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    func addAlignedConstrains() {
        translatesAutoresizingMaskIntoConstraints = false
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.top)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.leading)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.trailing)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.bottom)
    }

    func addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute) {
        superview?.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: superview,
                attribute: attribute,
                multiplier: 1,
                constant: 0
            )
        )
    }

}
/// 高斯模糊
class BlurView {
    
    private var superview: UIView
    private var blur: UIVisualEffectView?
    private var editing: Bool = false
    private (set) var blurContentView: UIView?
    private (set) var vibrancyContentView: UIView?
    
    var animationDuration: TimeInterval = 0.1
    
    /**
     * Blur style. After it is changed all subviews on
     * blurContentView & vibrancyContentView will be deleted.
     */
    var style: UIBlurEffect.Style = .light {
        didSet {
            guard oldValue != style,
                  !editing else { return }
            applyBlurEffect()
        }
    }
    /**
     * Alpha component of view. It can be changed freely.
     */
    var alpha: CGFloat = 0 {
        didSet {
            guard !editing else { return }
            if blur == nil {
                applyBlurEffect()
            }
            let alpha = self.alpha
            UIView.animate(withDuration: animationDuration) {
                self.blur?.alpha = alpha
            }
        }
    }
    
    init(to view: UIView) {
        self.superview = view
    }
    
    func setup(style: UIBlurEffect.Style, alpha: CGFloat) -> Self {
        self.editing = true
        
        self.style = style
        self.alpha = alpha
        
        self.editing = false
        
        return self
    }
    
    func enable(isHidden: Bool = false) {
        if blur == nil {
            applyBlurEffect()
        }
        
        self.blur?.isHidden = isHidden
    }
    
    private func applyBlurEffect() {
        blur?.removeFromSuperview()
        
        applyBlurEffect(
            style: style,
            blurAlpha: alpha
        )
    }
    
    private func applyBlurEffect(style: UIBlurEffect.Style,
                                 blurAlpha: CGFloat) {
        superview.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        blurEffectView.contentView.addSubview(vibrancyView)
        
        blurEffectView.alpha = blurAlpha
        
        superview.insertSubview(blurEffectView, at: 0)
        
        blurEffectView.addAlignedConstrains()
        vibrancyView.addAlignedConstrains()
        
        self.blur = blurEffectView
        self.blurContentView = blurEffectView.contentView
        self.vibrancyContentView = vibrancyView.contentView
    }
}
