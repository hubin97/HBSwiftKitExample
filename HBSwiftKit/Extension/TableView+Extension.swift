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
    func indexPath(subView: UIView) -> IndexPath? {
        return self.indexPathForRow(at: subView.convert(CGPoint.zero, to: self))
    }
    
    /// 根据cell子视图获取当前UITableViewCell?
    /// - Parameter subView: 子视图
    /// - Returns: UITableViewCell?
    func cell(subView: UIView) -> UITableViewCell? {
        guard let indexPath = self.indexPath(subView: subView) else { return nil }
        return self.cellForRow(at: indexPath)
    }
    
    /// 便捷注册cell
    /// - Parameter type: cell类
    func register<T: UITableViewCell>(_ type: T.Type) {
        self.register(type.classForCoder(), forCellReuseIdentifier: NSStringFromClass(type.classForCoder()))
    }
    
    /// 获取复用cell
    /// - Parameter type: cell类
    /// - Returns: 复用cell
    func getReusableCell<T: UITableViewCell>( _ type: T.Type) -> T {
        return self.dequeueReusableCell(withIdentifier: NSStringFromClass(type.classForCoder())) as! T
    }
}

//MARK: - call backs
extension TableView_Extension {
    
}

//MARK: - delegate or data source
extension TableView_Extension {
    
}

//MARK: - other classes
//MARK: - UICollectionView复用注入
extension UICollectionView {
    
    /// 便捷注册cell
    /// - Parameter type: cell类
    func register<T: UICollectionViewCell>(_ type: T.Type) {
        self.register(type.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(type.classForCoder()))
    }
    
    /// 获取复用cell
    /// - Parameter type: cell类
    /// - Returns: 复用cell
    func getReusableCell<T: UICollectionViewCell>(_ indexPath: IndexPath, _ type: T.Type) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(type.classForCoder()), for: indexPath) as! T
    }
}
