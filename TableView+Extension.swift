//
//  TableView+Extension.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/1/20.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

//MARK: - global var and methods
public typealias TableView_Extension = UITableView

//MARK: - main class
extension TableView_Extension {

    /// 根据cell子视图获取IndexPath?
    /// - Parameter subView: 子视图
    /// - Returns: IndexPath?
    func indexPath(by subView: UIView) -> IndexPath? {
        return self.indexPathForRow(at: subView.convert(CGPoint.zero, to: self))
    }
    
    /// 根据cell子视图获取当前UITableViewCell?
    /// - Parameter subView: 子视图
    /// - Returns: UITableViewCell?
    func cell(by subView: UIView) -> UITableViewCell? {
        guard let indexPath = self.indexPath(by: subView) else { return nil }
        return self.cellForRow(at: indexPath)
    }
}

//MARK: - call backs
extension TableView_Extension {
    
}

//MARK: - delegate or data source
extension TableView_Extension {
    
}

//MARK: - other classes
