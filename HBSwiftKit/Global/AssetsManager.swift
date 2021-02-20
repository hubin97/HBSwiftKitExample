//
//  AssetsManager.swift
//  IOTC
//
//  Created by Hubin_Huang on 2020/5/8.
//  Copyright © 2020 Hubin_Huang. All rights reserved.
//

import UIKit
import Foundation

/// 参考 R.swift https://github.com/mac-cain13/R.swift
/**
 1.Build Phases-> Run Script(放Dependencies后面)
   (1)shell: "$SRCROOT/Pods/R.swift/rswift" generate "$SRCROOT/Resources/R.generated.swift"
   (2)Based on dependency analysis选项不勾选,(相当于每次build都去更新R.generated.swift文件)
   (3)Input Files: $TEMP_DIR/rswift-lastrun
   (4)Output Files: $SRCROOT/Resources/R.generated.swift
 2.注意(1)中Resources即为自动生成的R.generated.swift的路径,导入时无需勾选 copy items if needed
 3.注意版本兼容性, Assets.xcassets加入Color set仅支持 >= iOS11
 */

public enum Assets {
    
    enum image {
        static var appIcon = UIImage(named: "iotc")
    }
    
    enum font {
        static func left_menu_logo(_ size: CGFloat) ->UIFont {
            UIFont(name: "Zapfino", size: size)!
        }
    }
    
    enum color {
        static var theme = UIColor.lightGray
    }
}
