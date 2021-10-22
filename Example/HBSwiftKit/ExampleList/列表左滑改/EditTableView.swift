//
//  EditTableView.swift
//  WingToSmart
//
//  Created by hubin.h@wingto.cn on 2020/8/18.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation

// MARK: - global var and methods
private let deleteIcon = UIImage(named: "cellRightDelet")

// MARK: - main class

class EditTableView: UITableView {

}

/**
(1).iOS10下视图层次为：
 UITableView -> UITableViewCell -> UITableViewCellDeleteConfirmationView -> _UITableViewCellActionButton，我们所需自定义的按钮视图UITableViewCellDeleteConfirmationView（左图中红框处）是UITableViewCell的子视图。

(2).iOS11下视图层次为：
 在Xcode 8中编译为: UITableView -> UITableViewWrapperView -> UISwipeActionPullView -> UISwipeActionStandardButton；
 在Xcode 9中编译为: UITableView -> UISwipeActionPullView -> UISwipeActionStandardButton。
 （iOS11中用Xcode 8和Xcode 9中编译有略微的差别），我们所需自定义的按钮视图UISwipeActionPullView（右图中红框处）是UITableView的子视图。
(3).iOS13下视图层次为：
 在Xcode 11中编译为: UITableView -> _UITableViewCellSwipeContainerView -> UISwipeActionPullView -> UISwipeActionStandardButton；
 
 另外参考: 自定义设置iOS8-10系统下的左滑删除按钮大小
 https://www.jianshu.com/p/b258b55e4a5c
*/

// MARK: - private mothods
extension EditTableView {

    /// 关闭复杂度校验
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    override func layoutSubviews() {
        super.layoutSubviews()

        var deleteButton: UIButton?

        // UISwipeActionPullView
        if #available(iOS 13.0, *) {
            for view in self.subviews {
                if view.isKind(of: NSClassFromString("_UITableViewCellSwipeContainerView") ?? UIView.self) {

                    for subView in view.subviews {
                        if subView.isKind(of: NSClassFromString("UISwipeActionPullView") ?? UIView.self) {
                            subView.backgroundColor = .clear

                            for btnView in subView.subviews {
                                if btnView.isKind(of: NSClassFromString("UISwipeActionStandardButton") ?? UIView.self) {
                                    deleteButton = btnView as? UIButton
                                    deleteButton?.frame = btnView.bounds
                                    subView.layoutIfNeeded()
                                    subView.setNeedsLayout()
                                }
                            }
                        }
                    }
                }
            }
        } else if #available(iOS 11.0, *) {

            for subView in self.subviews {
                if subView.isKind(of: NSClassFromString("UISwipeActionPullView") ?? UIView.self) {
                    subView.backgroundColor = .clear

                    for btnView in subView.subviews {
                        if btnView.isKind(of: NSClassFromString("UISwipeActionStandardButton") ?? UIView.self) {
                            deleteButton = btnView as? UIButton
                            deleteButton?.frame = btnView.bounds
                            subView.layoutIfNeeded()
                            subView.setNeedsLayout()
                        }
                    }
                }
            }
        } else {

            for view in self.subviews {
                if view.isKind(of: NSClassFromString("UITableViewWrapperView") ?? UIView.self) {

                    for subView in view.subviews {
                        if subView.isKind(of: UITableViewCell.self) {

                            for subView2 in subView.subviews {
                                if subView2.isKind(of: NSClassFromString("UITableViewCellDeleteConfirmationView") ?? UIView.self) {
                                    subView2.backgroundColor = .clear

                                    if subView2.subviews.count > 0 {
                                        deleteButton = subView2.subviews.first as? UIButton
                                        deleteButton?.frame = subView2.bounds
                                        subView2.layoutIfNeeded()
                                        subView2.setNeedsLayout()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        guard let deleteBtn = deleteButton else { return }

        deleteBtn.setImage(deleteIcon, for: .normal)
        deleteBtn.setTitle(nil, for: .normal)
        // deleteBtn.imageView?.contentMode = .scaleAspectFit
        deleteBtn.layer.masksToBounds = true

        // iOS 13 UISwipeActionStandardButton 子视图包含一个view
        for tmpView in deleteBtn.subviews {
            tmpView.backgroundColor = .clear
        }

    }
}
