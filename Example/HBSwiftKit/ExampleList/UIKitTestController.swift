//
//  UIKitTestController.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/2/26.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

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
    var isExpand = false
    
    override func setupUi() {
        super.setupUi()
        
        self.title = "UIKit测试页"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "筛选", style: .plain, target: self, action: #selector(filterAction))
                
        rulerView = SliderRuler.init(frame: CGRect(x: 20, y: 150, width: 50, height: 400), direction: .vertical, rulerLineSpacing: 15)
        view.addSubview(rulerView)
        rulerView.setRoundCorners()
        
        let rulerView2 = SliderRuler.init(frame: CGRect(x: 20, y: 0, width: kScreenWidth - 40, height: 50), direction: .horizontal, rulerLineSpacing: 15)
        view.addSubview(rulerView2)
        rulerView2.setRoundCorners()
    }
}

//MARK: - private mothods
extension UIKitTestController {
    
}

//MARK: - call backs
extension UIKitTestController {
    
    @objc func filterAction() {
        
        let rulerValue = rulerView.rulerValue
        rulerView.removeFromSuperview()
        print("rulerView.rulerValue:\(rulerView.rulerValue)")
        isExpand = !isExpand
        if isExpand {
            rulerView = SliderRuler.init(frame: CGRect(x: 20, y: 50, width: 50, height: 400), direction: .vertical, rulerLineSpacing: 15)
        } else {
            rulerView = SliderRuler.init(frame: CGRect(x: 20, y: 50, width: 50, height: 200), direction: .vertical, rulerLineSpacing: 7)
        }
        view.addSubview(rulerView)
        rulerView.setRulerValue(rulerValue: rulerValue, animated: true)
        rulerView.setRoundCorners()

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
