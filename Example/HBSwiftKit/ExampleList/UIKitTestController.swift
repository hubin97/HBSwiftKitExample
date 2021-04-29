//
//  UIKitTestController.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/2/26.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import UIKit
import QuartzCore

//MARK: - global var and methods
//swift单元测试（八）总结 https://blog.csdn.net/lin1109221208/article/details/93486230?utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromMachineLearnPai2%7Edefault-8.control&dist_request_id=&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromMachineLearnPai2%7Edefault-8.control

//MARK: - main class
class UIKitTestController: BaseViewController {

    lazy var filterModels: [AdvancedFilterSecModel] = {
        let path = Bundle.main.path(forResource: "advfilterdata", ofType: "json")
        let url = URL(fileURLWithPath: path ?? "")
        
        do {
            let json = try JSONSerialization.jsonObject(with: Data.init(contentsOf: url), options: .mutableContainers)
            if let dic = json as? Dictionary<String, Any>, let datas = dic["data"] as? [[String: Any]] {
                var models = [AdvancedFilterSecModel]()
                for dict in datas {
                    let secModel = AdvancedFilterSecModel.init()
                    secModel.sectitle = dict.keys.first ?? ""
                    secModel.isExpanded = false
                    if let rowDatas = dict.values.first as? [String] {
                        for rowdata in rowDatas {
                            let rowModel = AdvancedFilterRowModel.init()
                            rowModel.rowtitle = rowdata
                            rowModel.isSelected = false
                            secModel.rowModels.append(rowModel)
                        }
                    }
                    models.append(secModel)
                }
                return models
            }
        } catch {
            print("tojsonErro: \(error)")
        }
        return []
    }()
    
    var rulerView: SliderRuler!
    //var isExpand = false
    let ball = UIImageView()
    
    @objc func btnAction1(_ sender: UIButton) {
        print("btnAction1")
    }
    
    @objc func btnAction2(_ sender: UIButton) {
        print("btnAction2")
    }
    
    @objc func btnAction3(_ sender: UIButton) {
        print("btnAction3")
    }
    
    override func setupUi() {
        super.setupUi()
        
        self.navigationItem.title = "UIKit Test"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "筛选", style: .plain, target: self, action: #selector(filterAction))
          
        let btn1 = UIButton.init(frame: CGRect(x: 20, y: 100, width: 300, height: 100))
        btn1.addTarget(self, action: #selector(btnAction1), for: .touchUpInside)
        btn1.setTitle("哈HH阿卡", for: .normal)
        btn1.setTitleColor(.black, for: .normal)
        btn1.titleLabel?.font = UIFont.systemFont(ofSize: kScaleW(30), weight: .semibold)
        btn1.drawTextLineColor = .orange
        btn1.drawTextLineWidth = 2
        view.addSubview(btn1)
        btn1.setRoundCorners(borderColor: .red)
        
        let btn2 = UIButton.init(frame: CGRect(x: 100, y: 300, width: 100, height: 100))
        btn2.addTarget(self, action: #selector(btnAction2), for: .touchUpInside)
        btn2.touchAreaInsets = UIEdgeInsetsMake(50, 50, 50, 50)
        view.addSubview(btn2)
        btn2.setRoundCorners(borderColor: .green)

        let btn3 = UIButton.init(type: .custom)
        btn3.frame = CGRect(x: 100, y: 500, width: 100, height: 100)
        btn3.setBackgroundImage(UIImage(color: .brown), for: .normal)
        btn3.addTarget(self, action: #selector(btnAction3), for: .touchUpInside)
        //btn3.touchAreaInsets = UIEdgeInsetsMake(50, 150, 50, 150)
        btn3.showScaleAnimate = true
        btn3.showScale = 1.2
        view.addSubview(btn3)
        btn3.setRoundCorners(borderColor: .blue)

//        // 刻度尺
//        rulerView = SliderRuler.init(frame: CGRect(x: 20, y: 150, width: 50, height: 400), direction: .vertical, rulerLineSpacing: 15, minValue: 15, maxValue: 40)
//        view.addSubview(rulerView)
//        rulerView.setRoundCorners()
//
//        let rulerView2 = SliderRuler.init(frame: CGRect(x: 20, y: 0, width: kScreenW - 40, height: 50), direction: .horizontal, rulerLineSpacing: 15, minValue: 16, maxValue: 32)
//        view.addSubview(rulerView2)
//        rulerView2.setRoundCorners()
        
//        view.addSubview(ball)
//        ball.frame = CGRect(x: 40, y: 200, width: 100, height: 100)
//        ball.backgroundColor = .brown
//        ball.setRectCorner(radiiSize: 50)
//
    }
}

//MARK: - private mothods
extension UIKitTestController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        let alert = Wto_AlertView.init(title: "New Device!", icon: "test", message: "AUKEY T7S", actions: ["Cancel", "Continue"]) { (index, title) in
//            print("index:\(index), title:\(title)")
//        }
//        let alert = Wto_AlertView.init(title: "New Device!", icon: "test", iconSize: CGSize(width: 40, height: 85), message: "AUKEY T7S", actions: ["Cancel", "Continue"]) { (index, title) in
//            print("index:\(index), title:\(title)")
//        }
//        alert.show()
//        let alert = Wto_AlertView.init(title: "New Device!", icon: R.image.tabBar.home_h.name, iconSize: CGSize(width: 40, height: 40), message: "AUKEY T7S")
//        alert.addAction("Cancel", .lightGray, tapAction: nil)
//        alert.addAction("Continue") {
//            print("Continue")
//        }
//        alert.show()
        //(title: "“Aukey Life” Wants To Use “Facebook.com” To Log In", message: "This will allow the App to share your information with the website", alertWidth: 250)
        
//        let alert = AlertView.init(Aukey_title: "“Aukey Life” Wants To Use “Facebook.com” To Log In", message: "This will allow the App to share your information with the website")
//        alert.addAction("Cancel", .lightGray, tapAction: nil)
//        alert.addAction("Continue") {
//            print("Continue")
//        }
//        alert.show()
        
//        let alert = Wto_AlertView.init(Aukey_title: "New Device!", icon: R.image.tabBar.home_h.name, message: "AUKEY T7S")
//        alert.addAction("Cancel", .lightGray, tapAction: nil)
//        alert.addAction("Continue") {
//            print("Continue")
//        }
//        alert.show()
        
        //YTHitView.show(message: "哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈")
        //YTHitView.show(message: "哈哈哈哈哈哈哈哈", position: .top)
//        let targetRect = CGRect(x: 10, y: kScreenHeight - kBottomSafeHeight - 65 - 135, width: kScreenWidth - 20, height: 65)
//        YTHitView.show(message: "哈哈哈哈哈哈哈哈", position: .none, noneRect: targetRect)
//        YTHitView.showSuccess(message: "操作成功")
//        YTHitView.showSuccess(message: "操作成功", position: .bottom)
//        YTHitView.showWarnning(message: "操作成功", position: .top)
//        YTHitView.showSuccess(message: "操作成功", position: .none, noneRect: targetRect, duration: 1)
//        YTHitView.setHitHeight(44).showSuccess(message: "OJBK!!!")
        //YTHitView.setHitWidth(200).setHitSuccImg("ib_select").showSuccess(message: "WTF???")
        
        /// R库不勾选provides namespace时, 获取到的图片名无效, 无法显示图片
//        let name = R.image.tabBar.home_h.name
//        YTHitView.setHitWidth(200).setHitSuccImg(name).showSuccess(message: "WTF???")
        
        //MFMessageComposeViewController
        AlertBlockView.init(title: "标题", message: "这是消息体", actions: ["我知道了"], tapAction: nil).show()

    }
    
    func bouncesAni() {
        let orignPoint = ball.center
        let animateKeyframes = CAKeyframeAnimation(keyPath: "position")
        animateKeyframes.duration = 2
        animateKeyframes.values = [NSValue(cgPoint: orignPoint),
                                   NSValue(cgPoint: CGPoint(x: orignPoint.x, y: orignPoint.y - 60)),
                                   NSValue(cgPoint: orignPoint),
                                   NSValue(cgPoint: CGPoint(x: orignPoint.x, y: orignPoint.y - 40)),
                                   NSValue(cgPoint: orignPoint),
                                   NSValue(cgPoint: CGPoint(x: orignPoint.x, y: orignPoint.y - 20)),
                                   NSValue(cgPoint: orignPoint),
                                   NSValue(cgPoint: CGPoint(x: orignPoint.x, y: orignPoint.y - 10)),
                                   NSValue(cgPoint: orignPoint)]
        animateKeyframes.keyTimes = [0, 0.2, 0.38, 0.52, 0.66, 0.76, 0.86, 0.93, 1]
        animateKeyframes.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                                            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        self.ball.layer.add(animateKeyframes, forKey: nil)
    }
}

public typealias AlertView = YTAlertView
extension AlertView {
    
    /** 默认间距变更
     // 标题与alert边框大间距
     fileprivate var kpadding = W_Scale(30)
     /// 标题与内容小间距
     fileprivate var s_kpadding = W_Scale(20)
     /// 左边距
     fileprivate var l_kpadding = W_Scale(15)
     */
    public convenience init(Aukey_title title: String?, message: String?, alertWidth: CGFloat = 250, kpadding: CGFloat = 30, s_kpadding: CGFloat = 20, l_kpadding: CGFloat = 15) {
        self.init(frame: CGRect.zero)
        self.alert_width = alertWidth
        self.kpadding = kpadding
        self.s_kpadding = s_kpadding
        self.l_kpadding = l_kpadding
        setup(title: title, message: message, actions: nil)
    }
    
    public convenience init(Aukey_title title: String?, icon: String?, iconSize: CGSize? = nil, message: String?, alertWidth: CGFloat = 250, kpadding: CGFloat = 30, s_kpadding: CGFloat = 20, l_kpadding: CGFloat = 15) {
        self.init(frame: CGRect.zero)
        self.alert_width = alertWidth
        self.kpadding = kpadding
        self.s_kpadding = s_kpadding
        self.l_kpadding = l_kpadding
        setup(title: title, icon: icon, iconSize: iconSize, message: message, actions: nil)
    }
}

//MARK: - call backs
extension UIKitTestController {
    
    @objc func filterAction() {
        
//        let rulerValue = rulerView.rulerValue
//        rulerView.removeFromSuperview()
//        print("rulerView.rulerValue:\(rulerView.rulerValue)")
//        isExpand = !isExpand
//        if isExpand {
//            rulerView = SliderRuler.init(frame: CGRect(x: 20, y: 50, width: 50, height: 400), direction: .vertical, rulerLineSpacing: 15)
//        } else {
//            rulerView = SliderRuler.init(frame: CGRect(x: 20, y: 50, width: 50, height: 200), direction: .vertical, rulerLineSpacing: 7)
//        }
//        view.addSubview(rulerView)
//        rulerView.setRulerValue(rulerValue: rulerValue, animated: true)
//        rulerView.setRoundCorners()

        // filterModels
//        let filterView = AdvancedFilter.init()
//        filterView.filterModels = self.filterModels
//        filterView.show()
    }
}

//MARK: - delegate or data source
extension UIKitTestController {
    
}

//MARK: - other classes


/// 正确设置标签行间距 默认 7
//fileprivate func setLabelLineSpacing(label: UILabel, lineSpacing: CGFloat = 7, _ alignment: NSTextAlignment = .center) -> [NSAttributedString.Key : Any]? {
//    let paragraphStyle = NSMutableParagraphStyle()
//    paragraphStyle.lineSpacing = lineSpacing - (label.font.lineHeight - label.font.pointSize)
//    paragraphStyle.alignment = alignment
//    let attributes = [NSAttributedString.Key.font: label.font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
//    return attributes as [NSAttributedString.Key : Any]
//}

