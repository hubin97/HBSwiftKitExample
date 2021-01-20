//
//  Label+Extension.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/1/20.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

//MARK: - global var and methods
public typealias Label_Extension = UILabel

//MARK: - main class
extension Label_Extension {

    public convenience init(text : String?, textColor : UIColor?, textFont : UIFont?, textAlignment: NSTextAlignment = .left, numberLines: Int = 1) {
        self.init()
        self.text = text
        self.textColor = textColor ?? UIColor.black
        self.font = textFont ?? UIFont.systemFont(ofSize: 17.0)
        self.textAlignment = textAlignment
        self.numberOfLines = numberLines
        self.clipsToBounds = false
    }

    /// 预计高度
    public func pre_h(maxWidth: CGFloat,maxLine:Int = 0) -> CGFloat {
        let label = UILabel(frame: CGRect(
            x: 0,
            y: 0,
            width: maxWidth,
            height: CGFloat.greatestFiniteMagnitude)
        )
        label.numberOfLines = 0
        label.backgroundColor = backgroundColor
        label.lineBreakMode = lineBreakMode
        label.font = font
        label.text = text
        label.textAlignment = textAlignment
        label.numberOfLines = maxLine
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
    // 预计宽度
    public func pre_w(maxHeight: CGFloat,maxLine:Int = 0) -> CGFloat {
        let label = UILabel(frame: CGRect(
            x: 0,
            y: 0,
            width: CGFloat.greatestFiniteMagnitude,
            height: maxHeight)
        )
        label.numberOfLines = 0
        label.backgroundColor = backgroundColor
        label.lineBreakMode = lineBreakMode
        label.font = font
        label.text = text
        label.textAlignment = textAlignment
        label.numberOfLines = maxLine
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.width
    }

}

//MARK: - private mothods
extension Label_Extension {
    
}

//MARK: - call backs
extension Label_Extension {
    
}

//MARK: - delegate or data source
extension Label_Extension {
    
}

//MARK: - other classes
