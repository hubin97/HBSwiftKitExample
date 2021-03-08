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
    
    //var rulerView: SliderRuler!
    //var isExpand = false
    let ball = UIImageView()
    
    override func setupUi() {
        super.setupUi()
        
        self.title = "UIKit Test"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "筛选", style: .plain, target: self, action: #selector(filterAction))
                
        // 刻度尺
//        rulerView = SliderRuler.init(frame: CGRect(x: 20, y: 150, width: 50, height: 400), direction: .vertical, rulerLineSpacing: 15)
//        view.addSubview(rulerView)
//        rulerView.setRoundCorners()
//
//        let rulerView2 = SliderRuler.init(frame: CGRect(x: 20, y: 0, width: kScreenWidth - 40, height: 50), direction: .horizontal, rulerLineSpacing: 15)
//        view.addSubview(rulerView2)
//        rulerView2.setRoundCorners()
        
        
        view.addSubview(ball)
        ball.frame = CGRect(x: 40, y: 200, width: 100, height: 100)
        ball.backgroundColor = .brown
        ball.setRectCorner(radiiSize: 50)
        
        var str = "ABCDEFG"
//        let tmp = str[2, 5]
//        print("tmp:\(tmp)")
//        let tmp2 = str[2, 7]
//        print("tmp2:\(tmp2)")
//
//        str[2, 4] = "cdef"
//        print("str:\(str)")
//        str[2, 7] = "cdefghijk"
//        print("str:\(str)")

        let tmp = str[0]
        print("tmp:\(tmp)")
        // Prints tmp:A

        let tmp2 = str[5]
        print("tmp2:\(tmp2)")
        // Prints tmp2:F

        str[5] = "*"
        print("str:\(str)")
        // Prints str:ABCDE*G
        
        str[1] = "###"
        print("str:\(str)")
        // Prints str:A###CDE*G
    }
}

//MARK: - private mothods
extension UIKitTestController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
