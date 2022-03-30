//
//  IndexTableView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2022/3/30.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit

protocol IndexTableViewDataSource: AnyObject {
    func indexTitles(for indexTableView: UITableView) -> [String]
}

class IndexTableView: UITableView, ViewReusePool {

    typealias T = UIButton
    var reuseQueue: ReusePoolQueue = ReusePoolQueue()

    weak var indexDataSource: IndexTableViewDataSource?
    lazy var containView: UIView = {
        let _containView = UIView.init(frame: CGRect.zero)
        _containView.backgroundColor = .white
        return _containView
    }()

    override func reloadData() {
        super.reloadData()
        self.superview?.insertSubview(containView, aboveSubview: self)
        self.reset()
        self.reloadIndexBar()
    }

    func reloadIndexBar() {
        self.containView.isHidden = false
        guard let indexTitles = indexDataSource?.indexTitles(for: self) else {
            self.containView.isHidden = true
            return
        }
        let count = indexTitles.count
        let btnWidth: CGFloat = 60
        let btnHeight: CGFloat = self.frame.height/CGFloat(count)
        indexTitles.enumerated().forEach { idx, title in
            var reuseBtn = self.dequeueReusableView()
            if reuseBtn == nil {
                print("Button 创建")
                reuseBtn = UIButton(type: .custom)
                addReuseView(reuseBtn!)
            } else {
                print("Button 重用")
            }
            //let reuseBtn = self.dequeueReusableView() ?? UIButton(type: .custom)
            containView.addSubview(reuseBtn!)
            reuseBtn!.frame = CGRect(x: 0, y: CGFloat(idx) * btnHeight, width: btnWidth, height: btnHeight)
            reuseBtn!.setTitle(title, for: .normal)
            reuseBtn!.setTitleColor(.black, for: .normal)
            reuseBtn!.setBackgroundImage(UIImage(color: .white), for: .normal)
        }
        containView.frame = CGRect(x: self.frame.width - btnWidth, y: self.frame.origin.y, width: btnWidth, height: self.frame.height)
    }

}
