//
//  Extension+ScrollView.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/3/9.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

//MARK: - global var and methods
public typealias Extension_ScrollView = UIScrollView

//MARK: - main class

//MARK: - private mothods
extension Extension_ScrollView {
    
    ///  Scroll content to top with animation.
    /// - Parameter animated: defalut true
    public func scrollToTopAnimated(animated: Bool = true) {
        var off = self.contentOffset
        off.y = 0 - self.contentInset.top
        self.setContentOffset(off, animated: animated)
    }
    
    ///  Scroll content to bottom with animation.
    /// - Parameter animated: defalut true
    public func scrollToBottomAnimated(animated: Bool = true) {
        var off = self.contentOffset
        off.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom
        self.setContentOffset(off, animated: animated)
    }
    
    ///  Scroll content to left with animation.
    /// - Parameter animated: defalut true
    public func scrollToLeftAnimated(animated: Bool = true) {
        var off = self.contentOffset
        off.x = 0 - self.contentInset.left
        self.setContentOffset(off, animated: animated)
    }
    
    ///  Scroll content to right with animation.
    /// - Parameter animated: defalut true
    public func scrollToRightAnimated(animated: Bool = true) {
        var off = self.contentOffset
        off.x = self.contentSize.width - self.bounds.size.width + self.contentInset.right
        self.setContentOffset(off, animated: animated)
    }
}

//MARK: - call backs
extension Extension_ScrollView {
    
}

//MARK: - delegate or data source
extension Extension_ScrollView {
    
}

//MARK: - other classes
