//
//  DataExtension.swift
//  test
//
//  Created by hubin.h@wingto.cn on 2020/8/11.
//  Copyright © 2020 WingTo. All rights reserved.

import Foundation

extension Data {
    
    func toDic() -> Dictionary<String, Any>? {
        
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            let dic = json as! Dictionary<String, Any>
            return dic
            
        } catch _ {
            return nil
        }
    }
    
    
    func toArray() -> [Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            let array = json as! [Any]
            return array
            
        } catch _ {
            return nil
        }
    }
    
    func toString() -> String? {
      
        return String(data: self, encoding: String.Encoding.utf8)
    }
    
    func toDataString() -> String? {
         return String(format: "%@", self as CVarArg)
    }
    
    func tojson() -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: self , options: .allowFragments) as AnyObject
        } catch {
            print("tojsonErro: \(error)")
        }
        return nil
    }
}
