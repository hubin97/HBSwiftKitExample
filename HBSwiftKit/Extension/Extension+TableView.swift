//
//  Extension+TableView.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/1/20.
//  Copyright © 2020 Wingto. All rights reserved.

//单元测试 ✅
import Foundation

//MARK: - global var and methods
fileprivate typealias Extension_TableView = UITableView

//MARK: - main class
extension Extension_TableView {

    /// 根据cell子视图获取IndexPath?
    /// - Parameter subView: 子视图
    /// - Returns: IndexPath?
    public func indexPath(subView: UIView) -> IndexPath? {
        return self.indexPathForRow(at: subView.convert(CGPoint.zero, to: self))
    }
    
    ///  清空所有选中行状态.
    /// - Parameter animated: defalut true
    public func clearSelectedRowsAnimated(_ animated: Bool = true) {
        let indexs = self.indexPathsForSelectedRows
        indexs?.forEach({ (path) in
            self.deselectRow(at: path, animated: animated)
        })
    }
    
    /// 根据cell子视图获取当前UITableViewCell?
    /// - Parameter subView: 子视图
    /// - Returns: UITableViewCell?
    public func getCell(subView: UIView) -> UITableViewCell? {
        guard let indexPath = self.indexPath(subView: subView) else { return nil }
        return self.cellForRow(at: indexPath)
    }
    
    /// 便捷注册cell
    /// - Parameter type: cell类
    public func registerCell<T: UITableViewCell>(_ type: T.Type) {
        self.register(type.classForCoder(), forCellReuseIdentifier: NSStringFromClass(type.classForCoder()))
    }
    
    /// 获取复用cell
    /// - Parameter type: cell类
    /// - Returns: 复用cell
    public func getReusableCell<T: UITableViewCell>( _ type: T.Type) -> T {
        return self.dequeueReusableCell(withIdentifier: NSStringFromClass(type.classForCoder())) as! T
    }

    /// 便捷注册段头/尾视图
    public func registerView<T: UITableViewHeaderFooterView>(_ type: T.Type) {
        self.register(type.classForCoder(), forHeaderFooterViewReuseIdentifier: NSStringFromClass(type.classForCoder()))
    }

    /// 获取复用段头/尾视图
    public func getReusableView<T: UITableViewHeaderFooterView>( _ type: T.Type) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(type.classForCoder())) as! T
    }
}

//MARK: - call backs
extension Extension_TableView {
    
}

//MARK: - delegate or data source
extension Extension_TableView {
    
}

//MARK: - other classes
//MARK: - UICollectionView复用注入
extension UICollectionView {

    /// 段头/尾复用标识
    public enum ReusableKind {
        case header //= elementKindSectionHeader
        case footer //= .elementKindSectionFooter
        var rawValue: String {
            switch self {
            case .header:
                return UICollectionView.elementKindSectionHeader
            case .footer:
                return UICollectionView.elementKindSectionFooter
            }
        }
    }

    /// 便捷注册cell
    /// - Parameter type: cell类
    public func registerCell<T: UICollectionViewCell>(_ type: T.Type) {
        self.register(type.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(type.classForCoder()))
    }
    
    /// 获取复用cell
    /// - Parameter type: cell类
    /// - Returns: 复用cell
    public func getReusableCell<T: UICollectionViewCell>(_ indexPath: IndexPath, _ type: T.Type) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(type.classForCoder()), for: indexPath) as! T
    }

    /// 便捷注册段头/尾视图
    public func registerView<T: UICollectionReusableView>(_ kind: UICollectionView.ReusableKind, _ type: T.Type) {
        self.register(type.classForCoder(), forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: NSStringFromClass(type.classForCoder()))
    }

    /// 获取复用段头/尾视图
    public func getReusableView<T: UICollectionReusableView>(_ kind: UICollectionView.ReusableKind, _ indexPath: IndexPath, _ type: T.Type) -> T {
        return self.dequeueReusableSupplementaryView(ofKind: kind.rawValue, withReuseIdentifier: NSStringFromClass(type.classForCoder()), for: indexPath) as! T
    }
}
