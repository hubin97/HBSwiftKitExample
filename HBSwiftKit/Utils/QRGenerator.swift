//
//  QRGenerator.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/3/11.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import AVFoundation

//MARK: - global var and methods

//MARK: - main class
/// 条形码,二维码扫描生成类
open class QRGenerator {
}

//MARK: - private mothods
extension QRGenerator {
    
    /// 生成二维码
    /// - Parameters:
    ///   - text: 目标字符串
    ///   - width: 大小,  默认100 * 100
    ///   - fillImage: 中间logo
    ///   - color: 渲染颜色
    /// - Returns: 二维码图片
    public class func makeQRCode(text: String, width: CGFloat = 300, fillImage: UIImage? = nil, color: UIColor? = nil) -> UIImage? {
        guard let data = text.data(using: .utf8) else { return nil }
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            // 设置生成的二维码的容错率; value = @"L/M/Q/H"
            filter.setValue("H", forKey: "inputCorrectionLevel")
            // 获取生成的二维码
            guard let outPutImage = filter.outputImage else { return nil }
            
            // 设置二维码颜色
            let colorFilter = CIFilter(name: "CIFalseColor", parameters: ["inputImage":outPutImage,"inputColor0":CIColor(cgColor: color?.cgColor ?? UIColor.black.cgColor),"inputColor1":CIColor(cgColor: UIColor.clear.cgColor)])
            // 获取带颜色的二维码
            guard let newOutPutImage = colorFilter?.outputImage else { return nil }
            
            let scale = width/newOutPutImage.extent.width
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            let output = newOutPutImage.transformed(by: transform)
            let QRCodeImage = UIImage(ciImage: output)
            guard let fillImage = fillImage else { return QRCodeImage }
            
            let imageSize = QRCodeImage.size
            UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
            QRCodeImage.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
            let fillRect = CGRect(x: (width - width/5)/2, y: (width - width/5)/2, width: width/5, height: width/5)
            fillImage.draw(in: fillRect)
            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return QRCodeImage }
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
    
    /// 生成条形码
    /// - Parameters:
    ///   - text: 目标字符串
    ///   - size: 大小
    ///   - color: 渲染颜色
    /// - Returns: 条形码图片
    public class func makeBarCode(text:String, size:CGSize, color:UIColor? = nil) -> UIImage? {
        guard let data = text.data(using: .utf8) else { return nil }
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setDefaults()
            filter.setValue(data, forKey: "inputMessage")
            // 获取生成的条形码
            guard let outPutImage = filter.outputImage else { return nil }
            
            // 设置条形码颜色
            let colorFilter = CIFilter(name: "CIFalseColor", parameters: ["inputImage":outPutImage,"inputColor0":CIColor(cgColor: color?.cgColor ?? UIColor.black.cgColor),"inputColor1":CIColor(cgColor: UIColor.clear.cgColor)])
            // 获取带颜色的条形码
            guard let newOutPutImage = colorFilter?.outputImage else { return nil }
            
            let scaleX:CGFloat = size.width/newOutPutImage.extent.width
            let scaleY:CGFloat = size.height/newOutPutImage.extent.height
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            let output = newOutPutImage.transformed(by: transform)
            let barCodeImage = UIImage(ciImage: output)
            return barCodeImage
        }
        return nil
    }
}

//MARK: - call backs
extension QRGenerator {
    
}

//MARK: - delegate or data source
extension QRGenerator {
    
}

//MARK: - other classes
//extension AVMetadataObject.ObjectType {
//
//    public static let upca:AVMetadataObject.ObjectType = .init(rawValue: "org.gs1.UPC-A")
//
//    /// `AVCaptureMetadataOutput` metadata object types.
//    public static var metadata = [
//        AVMetadataObject.ObjectType.aztec,
//        AVMetadataObject.ObjectType.code128,
//        AVMetadataObject.ObjectType.code39,
//        AVMetadataObject.ObjectType.code39Mod43,
//        AVMetadataObject.ObjectType.code93,
//        AVMetadataObject.ObjectType.dataMatrix,
//        AVMetadataObject.ObjectType.ean13,
//        AVMetadataObject.ObjectType.ean8,
//        AVMetadataObject.ObjectType.face,
//        AVMetadataObject.ObjectType.interleaved2of5,
//        AVMetadataObject.ObjectType.itf14,
//        AVMetadataObject.ObjectType.pdf417,
//        AVMetadataObject.ObjectType.qr,
//        AVMetadataObject.ObjectType.upce
//    ]
//}
