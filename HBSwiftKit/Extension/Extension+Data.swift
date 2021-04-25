//
//  Extension+Data.swift
//  test
//
//  Created by hubin.h@wingto.cn on 2020/8/11.
//  Copyright © 2020 WingTo. All rights reserved.

import Foundation

fileprivate typealias Extension_Data = Data

extension Extension_Data {
    
    /// Data To Dictionary
    /// - Returns: Dictionary?
    public func toDict() -> Dictionary<String, Any>? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            let dic = json as! Dictionary<String, Any>
            return dic
        } catch _ {
            return nil
        }
    }
    
    /// Data To Array
    /// - Returns: Array?
    public func toArray() -> [Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            let array = json as! [Any]
            return array
        } catch _ {
            return nil
        }
    }
    
    /// Data To String
    /// - Returns: String?
    public func toString() -> String? {
        return String(data: self, encoding: String.Encoding.utf8)
    }
    
    /// Data To jsonObject
    /// - Returns: AnyObject?
    public func toJson() -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: self , options: .allowFragments) as AnyObject
        } catch {
            print("tojsonErro: \(error)")
        }
        return nil
    }
    
    func toDataString() -> String? {
         return String(format: "%@", self as CVarArg)
    }
}

extension Extension_Data {
    
    public enum ImageType {
        case unknown
        case jpeg
        case tiff
        case bmp
        case ico
        case icns
        case gif
        case png
        case webp
    }
    
    /// 获取图片Data时格式
    /// https://www.jianshu.com/p/2b90f8876bf0
    /// - Returns: 格式
    public func imageType() -> Data.ImageType {
        return self.detectImageType()
    }
    
    private func detectImageType() -> Data.ImageType {
        if self.count < 16 { return .unknown }
        
        var value = [UInt8](repeating:0, count:1)
        self.copyBytes(to: &value, count: 1)
        
        switch value[0] {
        case 0x4D, 0x49:
            return .tiff
        case 0x00:
            return .ico
        case 0x69:
            return .icns
        case 0x47:
            return .gif
        case 0x89:
            return .png
        case 0xFF:
            return .jpeg
        case 0x42:
            return .bmp
        case 0x52:
            let subData = self.subdata(in: Range(NSMakeRange(0, 12))!)
            if let infoString = String(data: subData, encoding: .ascii) {
                if infoString.hasPrefix("RIFF") && infoString.hasSuffix("WEBP") {
                    return .webp
                }
            }
            break
        default:
            break
        }
        return .unknown
    }
    
//    public func imageType(with url: URL) -> Data.ImageType {
//        if let data = try? Data(contentsOf: url) {
//            return data.detectImageType()
//        } else {
//            return .unknown
//        }
//    }
//
//    public func imageType(with filePath: String) -> Data.ImageType {
//        let pathUrl = URL(fileURLWithPath: filePath)
//        if let data = try? Data(contentsOf: pathUrl) {
//            return data.detectImageType()
//        } else {
//            return .unknown
//        }
//    }
//
//    public func imageType(with imageName: String, bundle: Bundle = Bundle.main) -> Data.ImageType? {
//        guard let path = bundle.path(forResource: imageName, ofType: "") else { return nil }
//        let pathUrl = URL(fileURLWithPath: path)
//        if let data = try? Data(contentsOf: pathUrl) {
//            return data.detectImageType()
//        } else {
//            return nil
//        }
//    }
}
