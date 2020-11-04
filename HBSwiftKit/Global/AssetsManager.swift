//
//  AssetsManager.swift
//  IOTC
//
//  Created by Hubin_Huang on 2020/5/8.
//  Copyright © 2020 Hubin_Huang. All rights reserved.
//

import UIKit
import Foundation

public enum Assets {
    
    enum image {
        
        static var appIcon = UIImage(named: "iotc")
    }
    
    enum font {
        
        //static var theme = UIColor.lightGray
        static func left_menu_logo(_ size: CGFloat) ->UIFont {
            UIFont(name: "Zapfino", size: size)!
        }
    }
    
    enum color {
        
        static var theme = UIColor.lightGray
    }
}
