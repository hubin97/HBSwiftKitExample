//
//  SliderRuler.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/2/23.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

//MARK: - global var and methods
fileprivate let rulerLineWidth = 1.5
/// 刻度线短线
fileprivate let rulerLineShort = 17
/// 刻度线长线
fileprivate let rulerLineLong  = 30
/// 刻度指示线长度
fileprivate let flagLineLength = 45

protocol SliderRulerDelegate: class {
    func sliderRulerValueUpdate(sliderRuler: SliderRuler, value: Float)
}
//MARK: - main class
class SliderRuler: UIView {
    
    /// 刻度尺代理
    weak var rulerDelegate: SliderRulerDelegate?
    /// 是否被禁用交互
    var isEnabled = false {
        didSet {
            flagColor = isEnabled ? .red: .gray
            rulerCollection.isUserInteractionEnabled = isEnabled
        }
    }
    
    /// 刻度值方向
    fileprivate var direction: UICollectionView.ScrollDirection = .horizontal
    
    /// 共多少个刻度 分多少个区
    fileprivate var stepNum: Int = 0
    /// 两个长刻度中间包括多少个刻度
    fileprivate var betweenNum: Int = 0
    /// 刻度间间距长度 (使用整型有效规避滚动偏移误差)
    fileprivate var rulerLineSpacing: Int = 10

    fileprivate var minValue: Float = 0.0
    fileprivate var maxValue: Float = 100.0
    /// 间隔值，每两条相隔多少值
    fileprivate var stepValue: Float = 1.0
    /// 最后指向刻度值
    var rulerValue: Float = 0.0
    /// 刻度线颜色
    var rulerColor: UIColor = .lightGray
    /// 标记线颜色
    var flagColor: UIColor = .red {
        didSet {
            flagLineView.backgroundColor = flagColor
        }
    }

    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = direction
        return layout
    }()
    
    lazy var rulerCollection: UICollectionView = {
        let rulerCollection = UICollectionView.init(frame: self.bounds, collectionViewLayout: self.layout)
        rulerCollection.backgroundColor = .clear
        rulerCollection.register(SliderRulerSpaceItem.self, forCellWithReuseIdentifier: "spacecell")
        rulerCollection.register(SliderRulerItem.self, forCellWithReuseIdentifier: "itemcell")
        rulerCollection.dataSource = self
        rulerCollection.delegate = self
        rulerCollection.showsHorizontalScrollIndicator = false
        rulerCollection.showsVerticalScrollIndicator = false
        return rulerCollection
    }()
    
    /// 指示线
    lazy var flagLineView: UIView = {
        let flagLineView = UIView()
        flagLineView.backgroundColor = .red
        if direction == .horizontal {
            flagLineView.frame = CGRect(x: self.bounds.width/2 - 1, y: self.bounds.height - CGFloat(flagLineLength), width: 2, height: CGFloat(flagLineLength))
        } else if direction == .vertical {
            flagLineView.frame = CGRect(x: self.bounds.width - CGFloat(flagLineLength), y: self.bounds.height/2 - 1, width: CGFloat(flagLineLength), height: 2)
        }
        return flagLineView
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// 滑动尺快捷初始化
    /// - Parameters:
    ///   - frame: 位置
    ///   - direction: 方向
    ///   - rulerLineSpacing: 刻度间间距长度 (使用整型有效规避滚动偏移误差)
    ///   - betweenNum: 长刻度中间区块格数
    ///   - stepNum: 总区块数
    ///   - minValue: 刻度最小值
    ///   - maxValue: 刻度最大值
    ///   - stepValue: 单格小刻度值
    convenience init(frame: CGRect, direction: UICollectionView.ScrollDirection, rulerLineSpacing: Int = 15, betweenNum: Int = 2, stepNum: Int = 50, minValue: Float = 1.0, maxValue: Float = 100.0, stepValue: Float = 1.0) {
        self.init(frame: frame)
        self.direction = direction
        self.rulerLineSpacing = rulerLineSpacing
        self.betweenNum = betweenNum
        self.stepNum = stepNum
        self.minValue = minValue
        self.maxValue = maxValue
        self.stepValue = stepValue
        
        addSubview(rulerCollection)
        addSubview(flagLineView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - private mothods
extension SliderRuler {
    
    /// 设定默认值
    /// - Parameters:
    ///   - rulerValue: 刻度值
    ///   - animated: 是否开启动画
    func setRulerValue(rulerValue: Float, animated: Bool) {
        self.rulerValue = rulerValue
        if direction == .horizontal {
            rulerCollection.setContentOffset(CGPoint(x: Int((rulerValue - minValue)/stepValue) * rulerLineSpacing, y: 0), animated: animated)
        } else {
            rulerCollection.setContentOffset(CGPoint(x: 0, y: Int((rulerValue - minValue)/stepValue) * rulerLineSpacing), animated: animated)
        }
    }
}

//MARK: - call backs
extension SliderRuler {
    
}

//MARK: - delegate or data source
extension SliderRuler: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        stepNum + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 || indexPath.item == stepNum + 1 {
            let spacecell = collectionView.dequeueReusableCell(withReuseIdentifier: "spacecell", for: indexPath) as! SliderRulerSpaceItem
            spacecell.backgroundColor = .clear
            spacecell.direction = direction
            spacecell.isFirstItem = indexPath.item == 0 ? true: false
            spacecell.setNeedsDisplay()
            return spacecell
        }
        let itemcell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemcell", for: indexPath) as! SliderRulerItem
        itemcell.backgroundColor = .clear
        itemcell.index = indexPath.item
        itemcell.direction = direction
        itemcell.betweenNum = betweenNum
        itemcell.stepNum = stepNum
        itemcell.rulerLineSpacing = rulerLineSpacing
        itemcell.minValue = minValue
        itemcell.maxValue = maxValue
        itemcell.setNeedsDisplay()
        return itemcell
    }
}

extension SliderRuler: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if direction == .vertical {
            if indexPath.item == 0 || indexPath.item == stepNum + 1 {
                return CGSize(width: Int(self.bounds.size.width), height: Int(self.bounds.size.height/2))
            }
            return CGSize(width: Int(self.bounds.size.width), height: rulerLineSpacing * betweenNum)
        }
        // 垂直情况
        if indexPath.item == 0 || indexPath.item == stepNum + 1 {
            return CGSize(width: Int(self.bounds.size.width/2), height: Int(self.bounds.size.height))
        }
        return CGSize(width: rulerLineSpacing * betweenNum, height: Int(self.bounds.size.height))
    }
}

extension SliderRuler: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == rulerCollection else { return }
        var offsetValue: Int = 0
        if direction == .horizontal {
            offsetValue = Int(scrollView.contentOffset.x) / rulerLineSpacing
        } else {
            offsetValue =  Int(scrollView.contentOffset.y) / rulerLineSpacing
        }
        var value = Float(offsetValue) * stepValue + minValue
        value = value > maxValue ? maxValue: value
        value = value < minValue ? minValue: value
        //print("isTracking:\(scrollView.isTracking) isDragging:\(scrollView.isDragging) isDecelerating:\(scrollView.isDecelerating)")
        /// 规避设置默认值错误回调
        guard self.rulerValue != value, scrollView.isDragging == true else { return }
        //print("rulerValue:\(value)")
        self.rulerValue = value
        rulerDelegate?.sliderRulerValueUpdate(sliderRuler: self, value: value)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            var offsetValue: CGFloat = 0
            if direction == .horizontal {
                offsetValue = scrollView.contentOffset.x / CGFloat(rulerLineSpacing)
                /// 规避区块划分多余的误差
                offsetValue = offsetValue > CGFloat(maxValue - minValue) ? CGFloat(maxValue - minValue): offsetValue
                scrollView.setContentOffset(CGPoint(x: Int(offsetValue) * rulerLineSpacing, y: 0), animated: true)
            } else {
                offsetValue = scrollView.contentOffset.y / CGFloat(rulerLineSpacing)
                offsetValue = offsetValue > CGFloat(maxValue - minValue) ? CGFloat(maxValue - minValue): offsetValue
                scrollView.setContentOffset(CGPoint(x: 0, y: Int(offsetValue) * rulerLineSpacing), animated: true)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var offsetValue: CGFloat = 0
        if direction == .horizontal {
            offsetValue = scrollView.contentOffset.x / CGFloat(rulerLineSpacing)
            offsetValue = offsetValue > CGFloat(maxValue - minValue) ? CGFloat(maxValue - minValue): offsetValue
            scrollView.setContentOffset(CGPoint(x: Int(offsetValue) * rulerLineSpacing, y: 0), animated: true)
        } else {
            offsetValue = scrollView.contentOffset.y / CGFloat(rulerLineSpacing)
            offsetValue = offsetValue > CGFloat(maxValue - minValue) ? CGFloat(maxValue - minValue): offsetValue
            scrollView.setContentOffset(CGPoint(x: 0, y: Int(offsetValue) * rulerLineSpacing), animated: true)
        }
    }
}

//MARK: - other classes
class SliderRulerItem: UICollectionViewCell {
    
    /// 刻度值方向
    var direction: UICollectionView.ScrollDirection = .horizontal
    /// 两个长刻度中间包括多少个刻度
    var betweenNum: Int = 0
    /// 共多少个刻度 分多少个区
    var stepNum = 0
    /// 刻度间间距长度
    var rulerLineSpacing: Int = 10
    /// 最小最大值
    var minValue: Float = 0.0
    var maxValue: Float = 100.0
    /// 区块下标
    var index: Int = 0
    /// 单位
    var unit: String = ""
    var valueFont = UIFont.systemFont(ofSize: 10)
    var valueColor = UIColor.black
    
    /// 显示刻度值
    var showValue = true
    
    override func draw(_ rect: CGRect) {
        let startX: CGFloat = 0
        let lineCenterX     = CGFloat(rulerLineSpacing)
        let shortLineY      = (direction == .horizontal) ? (rect.size.height - CGFloat(rulerLineLong)): (rect.size.width - CGFloat(rulerLineLong))
        let longLineY       = (direction == .horizontal) ? (rect.size.height - CGFloat(rulerLineShort)): rect.size.width - CGFloat(rulerLineShort)
        let topY: CGFloat   = (direction == .horizontal) ? rect.size.height: rect.size.width
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(CGFloat(rulerLineWidth))
        context?.setLineCap(CGLineCap.butt)
        //context?.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context?.setStrokeColor(UIColor.gray.cgColor)

        for i in 0...betweenNum {
            //print(i)
            // 目标总刻度数 跟区块对应不上, 去掉不必要的绘制
            if (Int(maxValue - minValue) / betweenNum != stepNum) && index == stepNum && i == betweenNum {
                //print("cancel index:\(index)")
                return
            }
            if direction == .horizontal {
                context?.move(to: CGPoint.init(x: startX+lineCenterX*CGFloat(i), y: topY))
                if i % betweenNum == 0 {
                    context!.addLine(to: CGPoint.init(x: startX+lineCenterX*CGFloat(i), y: longLineY))
                }else{
                    context!.addLine(to: CGPoint.init(x: startX+lineCenterX*CGFloat(i), y: shortLineY))
                }
            } else {
                context?.move(to: CGPoint.init(x: topY, y: startX+lineCenterX*CGFloat(i)))
                if i % betweenNum == 0 {
                    context!.addLine(to: CGPoint.init(x: longLineY, y: startX+lineCenterX*CGFloat(i)))
                }else{
                    context!.addLine(to: CGPoint.init(x: shortLineY, y: startX+lineCenterX*CGFloat(i)))
                }
            }
            context!.strokePath()
        }
    }
}

class SliderRulerSpaceItem: UICollectionViewCell {
    
    var direction: UICollectionView.ScrollDirection = .horizontal

    var headerMinValue = 0
    var headerUnit = ""
    
    //var unit: String = ""
    var valueFont = UIFont.systemFont(ofSize: 10)
    var valueColor = UIColor.black
    var isFirstItem = false

    override func draw(_ rect: CGRect) {
        guard isFirstItem else { return }
        //let longLineY = rect.size.height - CGFloat(rulerLineShort)
        let context = UIGraphicsGetCurrentContext()
        //context?.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context?.setStrokeColor(UIColor.gray.cgColor)
        context?.setLineWidth(CGFloat(rulerLineWidth))
        context?.setLineCap(CGLineCap.butt)
        if direction == .horizontal {
            context?.move(to: CGPoint(x: rect.size.width, y: rect.size.height - CGFloat(rulerLineShort)))
            context?.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
        } else {
            context?.move(to: CGPoint(x: rect.size.width - CGFloat(rulerLineShort), y: rect.size.height))
            context?.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
        }
        context?.strokePath()
    }
}
