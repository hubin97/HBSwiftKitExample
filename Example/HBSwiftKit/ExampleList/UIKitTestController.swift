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
    
    override func setupUi() {
        super.setupUi()
        
        self.title = "UIKit Test"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "筛选", style: .plain, target: self, action: #selector(filterAction))
                
        // 刻度尺
        rulerView = SliderRuler.init(frame: CGRect(x: 20, y: 150, width: 50, height: 400), direction: .vertical, rulerLineSpacing: 15, minValue: 15, maxValue: 40)
        view.addSubview(rulerView)
        rulerView.setRoundCorners()

        let rulerView2 = SliderRuler.init(frame: CGRect(x: 20, y: 0, width: kScreenWidth - 40, height: 50), direction: .horizontal, rulerLineSpacing: 15, minValue: 16, maxValue: 32)
        view.addSubview(rulerView2)
        rulerView2.setRoundCorners()
        
        
//        view.addSubview(ball)
//        ball.frame = CGRect(x: 40, y: 200, width: 100, height: 100)
//        ball.backgroundColor = .brown
//        ball.setRectCorner(radiiSize: 50)
//
//        var str = "ABCDEFG"
////        let tmp = str[2, 5]
////        print("tmp:\(tmp)")
////        let tmp2 = str[2, 7]
////        print("tmp2:\(tmp2)")
////
////        str[2, 4] = "cdef"
////        print("str:\(str)")
////        str[2, 7] = "cdefghijk"
////        print("str:\(str)")
//
//        let tmp = str[0]
//        print("tmp:\(tmp)")
//        // Prints tmp:A
//
//        let tmp2 = str[5]
//        print("tmp2:\(tmp2)")
//        // Prints tmp2:F
//
//        str[5] = "*"
//        print("str:\(str)")
//        // Prints str:ABCDE*G
//
//        str[1] = "###"
//        print("str:\(str)")
//        // Prints str:A###CDE*G
//        _ = QPath.filePaths(documentPath ?? "")
//        QPath.removeFile("")
////        QPath.createFile(name: "111.txt", fileBaseUrl: URL.init(fileURLWithPath: documentPath ?? ""))
////        QPath.createFile(name: "222.txt", fileBaseUrl: URL.init(fileURLWithPath: documentPath ?? ""))
//        QPath.writingToFile(filePath: "\(documentPath ?? "")/222.txt", contents: "啦啦啦啦")
//        QPath.writingToFile(filePath: "\(documentPath ?? "")/222.txt", contents: "\n哦哦哦哦")
//        let dicPath = QPath.createDirectory(basePath: "\(documentPath ?? "")", dicName: "Img")
//        QPath.createFile(filePath: "\(dicPath)/string", contents: "string")
//        QPath.createFile(filePath: "\(dicPath)/img", contents: R.image.tabBar.home_h()!)
//        if let img = R.image.tabBar.home_h(), let imgdata = UIImagePNGRepresentation(img) {
//            QPath.createFile(filePath: "\(dicPath)/data", contents: imgdata)
//        }
//
//        /**
//         ➜  Documents tree
//            .
//            ├── 111.txt
//            ├── 222.txt
//            └── Img
//                ├── data
//                ├── img
//                └── string
//
//            1 directory, 5 files
//         */
//
//        /**
//         (lldb) po String(data: FileManager.default.contents(atPath: "\(documentPath ?? "")/222.txt")!, encoding: String.Encoding.utf8)
//         ▿ Optional<String>
//           - some : "啦啦啦啦\n哦哦哦哦"
//         */
//
//        let testView = UIImageView.init(frame: CGRect(x: 200, y: 200, width: 100, height: 100))
//        view.addSubview(testView)
//        testView.backgroundColor = .white
//        //testView.setLayerShadow(color: .red, offset: CGSize(width: 3, height: 5), radius: 10)
//        //testView.setLayerCornerShadow(color: .red, offset: CGSize(width: 3, height: 5), radius: 10)
//        //let img = generateQRCode(text: "setLayerCornerShadow", width: 100)
//        testView.image = CodeScanner.makeQRCode(text: "哈哈哈--", width: 100, fillImage: R.image.tabBar.home_h(), color: .orange)
//        let zhs = ["埃尔派", "百世", "橙光", "黄河", "戴尔", "创维"]
//        zhs.map({ print("zh.toPinyin():\($0.toPinyin())") })
//        zhs.map({ print("zh.toPYHead():\($0.toPYHead())") })
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
        YTHitView.showWarnning(message: "操作成功", position: .top)
//        YTHitView.showSuccess(message: "操作成功", position: .none, noneRect: targetRect, duration: 1)
//        YTHitView.setHitHeight(44).showSuccess(message: "OJBK!!!")
        //YTHitView.setHitWidth(200).setHitSuccImg("ib_select").showSuccess(message: "WTF???")
        
        /// R库不勾选provides namespace时, 获取到的图片名无效, 无法显示图片
//        let name = R.image.tabBar.home_h.name
//        YTHitView.setHitWidth(200).setHitSuccImg(name).showSuccess(message: "WTF???")
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

public typealias AlertView = Wto_AlertView
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

