//
//  EasyAdScrollController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h@wingto.cn on 2020/12/7.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation

//MARK: - global var and methods

//MARK: - main class
class EasyAdScrollController: BaseViewController {

    override func setupUi() {
        super.setupUi()

        self.title = "标题轮播页"
        
        let titleSegment = TitleSegment.init(frame: CGRect(x: 0, y: 50, width: self.view.frame.width, height: 44), showStyle: .all, titles: ["AAA", "BBB", "CCC", "DDD", "EEE"], isShowOutstanding: true)
        view.addSubview(titleSegment)
        titleSegment.setRoundCorners(borderColor: .brown, borderWidth: 1, isDotted: true, lineDashPattern: [4, 1])
        titleSegment.setTargetIndex(with: 3)
        titleSegment.isNeedSeparateLine = true
        titleSegment.callBackTapTitleBlock = { (title, index) in
            print("index:\(index), title:\(title ?? "")")
        }
        
        let scrolldts = ["1.哈哈哈哈哈哈哈哈哈", "2.哦哦哦哦哦哦哦哦哦", "3.啦啦啦啦啦啦"]
        var i = 20;
        var items = [EasyAdScrollModel]()
        
        while (i >= 0) {
            for item in scrolldts {
                i -= 1
                let model = EasyAdScrollModel.init(iconName: "ib_share", flagName: nil, title: item)
                items.append(model)
            }
        }
        let adView = EasyAdScrollTool.init(frame: CGRect(x: 50, y: 200, width: 300, height: 44), style: .Page, datas: items)
        adView.setRoundCorners(borderColor: .systemBlue, borderWidth: 1, isDotted: true, lineDashPattern: [2, 4])
        view.addSubview(adView)
    }
}
