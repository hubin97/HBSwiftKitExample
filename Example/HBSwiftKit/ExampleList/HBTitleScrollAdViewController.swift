//
//  HBTitleScrollAdViewController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h@wingto.cn on 2020/12/7.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation

//MARK: - global var and methods

//MARK: - main class
class HBTitleScrollAdViewController: BaseViewController {

    override func setupUi() {
        super.setupUi()

        self.title = "标题轮播页"
        
        let titleView = HBTitleView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44), andTitles: ["AAA", "BBB", "CCC", "DDD", "EEE"], show: HBTITLESTYLE_All)
        view.addSubview(titleView!)
        titleView?.updataIndexLabelUI(withNum: 1)
        titleView?.isNeedBottomLine = true
        titleView?.isShowOutstanding = true
        titleView?.hb_titleBtnBlock = { [weak self] (index, title) in
            print("index:\(index), title:\(title ?? "")")
        }
        
        let scrolldts = ["1.哈哈哈哈哈哈哈哈哈", "2.哦哦哦哦哦哦哦哦哦", "3.啦啦啦啦啦啦"]
        var i = 20;
        var items = [HBScrollAdModel]()
        
        while (i >= 0) {
            for item in scrolldts {
                i -= 1
                let model = HBScrollAdModel()
                model.title = item
                model.iconName = "ib_share"
                items.append(model)
            }
        }
        let adView = HBScrollAdView.init(frame: CGRect(x: 50, y: 200, width: 300, height: 44))
        view.addSubview(adView)

        adView.layer.borderWidth = 1
        adView.layer.borderColor = UIColor.gray.cgColor
        adView.items = items
        adView.animationType = .leftRight
        adView.autoScroll = true
        adView.autoScrollTimeInterval = 4.0
    }
}

//MARK: - private mothods
extension HBTitleScrollAdViewController {
    
}

//MARK: - call backs
extension HBTitleScrollAdViewController {
    
}

//MARK: - delegate or data source
extension HBTitleScrollAdViewController {
    
}

//MARK: - other classes
