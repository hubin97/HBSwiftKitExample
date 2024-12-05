//
//  LineChartWrapper.swift
//  Momcozy
//
//  Created by hubin.h on 2023/12/19.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import DGCharts

// MARK: - global var and methods

// MARK: - main class
class LineChartWrapper: UIView {
    
//    lazy var marker: BalloonMarker = {
//        let _marker = BalloonMarker(color: Colors.thinBlack,
//                                    font: Fonts.medium14,
//                                    textColor: .white,
//                                    insets: UIEdgeInsets(top: 5, left: 5, bottom: 15, right: 5))
//        _marker.minimumSize = CGSize(width: 56, height: 35)
//        _marker.chartView = chartView
//        return _marker
//    }()
    
    lazy var marker: LTMarker = {
        let _marker = LTMarker(backgroundColor: Colors.thinBlack,
                               font: Fonts.medium14,
                               textColor: .white,
                               insets: UIEdgeInsets.zero)
        _marker.minimumSize = CGSize(width: 56, height: 35)
        _marker.chartView = chartView
        return _marker
    }()
    
    lazy var chartView: LineChartView = {
        let _chartView = LineChartView(frame: bounds)
        _chartView.doubleTapToZoomEnabled = false
        _chartView.scaleXEnabled = false
        _chartView.scaleYEnabled = false
        _chartView.dragEnabled = true
        _chartView.delegate = self
        //_lineChartView.noDataText = "没有数据别看了"
        return _chartView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(chartView)
        
        self.chartView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.setLegend()
        self.setXYAxis()
        self.chartView.marker = marker
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - private mothods
extension LineChartWrapper {
    
    func setChartData(_ lineSet: LineChartDataSet) {
        
        //!!!: 清除选中及数据
        chartView.clear()

        let data = generateLineData(lineSet)
        // FIXME: 调整bar两侧的边距
        //  chartView.xAxis.axisMinimum = data.xMin - 0.3
        //  chartView.xAxis.axisMaximum = data.xMax + 0.3
        chartView.data = data
        
        // FIXME: 注意下面的 ±0.2 是为了让图表的最左边和最右边的数据点不会被遮挡,
        // 根据业务而定的, 具体设置要看x轴的维度和颗粒度
        // 设置 X 轴的最小值和最大值
//        if let xMin = chartView.data?.xMin {
//            chartView.xAxis.axisMinimum = xMin - 0.2  // 设置 X 轴的最小值
//        }
        
        // 设置 X 轴的最大值, 增加颗粒度的 10%
        if let xMax = chartView.data?.xMax {
            let granularity = chartView.xAxis.granularity
            chartView.xAxis.axisMaximum = xMax + granularity * 0.1  // 设置 X 轴的最大值
        }
        
        // 设置最小最大, 可见的区域大小, 但是必须有数据
        // 注意, 与柱形图不一样, 分6段就是7个点
        chartView.setVisibleXRangeMinimum(6)
        chartView.setVisibleXRangeMaximum(6) // 设置x轴默认最大6个

        chartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5) // 开启动画
        chartView.notifyDataSetChanged()
    }
}

// MARK: - call backs
extension LineChartWrapper {
    
    func setLegend() {
        chartView.legend.enabled = false // 图例说明，不显示
        /// 图例位置
//        let l = chartView.legend
//        l.horizontalAlignment = .left
//        l.verticalAlignment = .top
//        l.orientation = .horizontal
//        l.drawInside = false
//        l.form = .none
//        l.formSize = 9
//        l.textColor = Colors.lightGray
//        //l.font = UIFont(name: "HelveticaNeue-Light", size: 12)!
//        l.xEntrySpace = 4
    }
    
    func setXYAxis() {
        //图表描述文字和样式
        //chartView.chartDescription.text = "本周统计"
        
        /// 水平分块 默认7
        let xAxisCount: Int = 7
        /// 垂直分块 默认6
        let yAxisCount: Int = 5

        /// X轴
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true // x轴线
        xAxis.drawLabelsEnabled = true // 是否显示标签
        xAxis.axisLineColor = Colors.chartLine // 轴线的颜色 和宽度
        xAxis.axisLineWidth = 1
     
        xAxis.labelFont = Fonts.regular12
        xAxis.labelTextColor = Colors.thinGray
//        xAxis.labelRotationAngle = 20 // 文字倾斜角度
        xAxis.setLabelCount(xAxisCount, force: false)  // 刻度标识12段
        //xAxis.forceLabelsEnabled = true
        xAxis.granularityEnabled = true
//        xAxis.axisMinimum = -0.5
        
        /// 左Y轴
        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .outsideChart // 刻度标签显示位置, 内部/外边
        leftAxis.drawGridLinesEnabled = true // 绘制网格线
        leftAxis.drawAxisLineEnabled = true  // 是否显示轴线
        leftAxis.drawLabelsEnabled = true // 是否显示标签
        leftAxis.drawZeroLineEnabled = false  //从0开始绘制 (此处为true会导致x轴线的颜色修改不了)
        //leftAxis.gridLineDashLengths = [8.0, 4.0]  // 虚线网格
        //leftAxis.axisLineDashPhase = 5
        leftAxis.gridColor = Colors.chartLine
        leftAxis.gridAntialiasEnabled = true  //开启抗锯齿
        leftAxis.axisLineColor = Colors.chartLine  // y轴线颜色
        leftAxis.axisLineWidth = 1
        leftAxis.labelFont = Fonts.regular12
        leftAxis.labelTextColor = Colors.thinGray
        
        leftAxis.axisMinimum = 0 // 设置y轴由0开始
        //leftAxis.axisMaximum = 100 // 最大值（不设置会根据数据自动设置）
        leftAxis.setLabelCount(yAxisCount, force: true) // 分几段

        chartView.rightAxis.enabled = false // 左侧Y轴，不显示

//        /// 右Y轴  ` 尽管不使用,但是也必须设置屏蔽`
//        let rightAxis = chartView.rightAxis
//        rightAxis.labelPosition = .outsideChart
//        rightAxis.drawGridLinesEnabled = false
//        rightAxis.drawAxisLineEnabled = false  // 是否显示轴线
//        rightAxis.drawLabelsEnabled = false // 是否显示标签
//        rightAxis.labelFont = UIFont.systemFont(ofSize: 10)
//        rightAxis.labelTextColor = Colors.lightGray
//        rightAxis.axisMinimum = 0
//        rightAxis.axisMaximum = 100 // 最大值（不设置会根据数据自动设置）
//        rightAxis.setLabelCount(yAxisCount, force: true) // 分几段
        
        // 添加单位后缀
//        let formatter = NumberFormatter()
//        formatter.positiveSuffix = " ml"
//        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        //        chartView.renderer = LTBarChartRenderer(dataProvider: chartView, animator: chartView.chartAnimator, viewPortHandler: chartView.viewPortHandler)
    }
    
    func generateLineData(_ lineSet: LineChartDataSet) -> LineChartData {
  
        let set = LineChartDataSet(entries: lineSet.entries, label: lineSet.label!)
        set.setColor(Colors.chartBarH) // 线条颜色
        set.lineWidth = 2
        set.drawCirclesEnabled = true  // 是否有转折点
        set.drawCircleHoleEnabled = true // 是否有空心
        set.setCircleColor(.white)
        set.circleHoleColor = Colors.chartBarH
        set.circleRadius = 6 //圆点外圆半径
        set.circleHoleRadius = 3  // 圆点内圆半径
        set.mode = .horizontalBezier   // 平滑曲线
        set.drawValuesEnabled = false  // 是否显示数值
        set.valueFont = .systemFont(ofSize: 12)
        set.valueTextColor = Colors.thinGray
        set.axisDependency = .left // 必须共用 //根据左y轴数据显示

        set.drawFilledEnabled = true
        let colors = [Colors.thinRed.cgColor, Colors.lightRed.cgColor]
        let cggradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: nil)
        set.fill = LinearGradientFill(gradient: cggradient!, angle: 90.0)
        set.fillAlpha = 1.0 // 阴影透明度
        
        set.highlightEnabled = false  /// 禁用折线点击事件

        /// 十字线
        set.highlightEnabled = true //不启用十字线
        set.highlightColor = .white
        set.highlightLineWidth = 2
        set.highlightLineDashLengths = [6, 6]
        set.drawVerticalHighlightIndicatorEnabled = true
        set.drawHorizontalHighlightIndicatorEnabled = false
        return LineChartData(dataSet: set)
    }
}

// MARK: - delegate or data source
extension LineChartWrapper: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        marker.setLabel(String(format: "%.2f", entry.y))
        
        //
//        //将选中的数据点的颜色改成黄色
//        var lchartDataSet = LineChartDataSet()
//        lchartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
//        let lineValues = lchartDataSet.entries
//        let index = lineValues.firstIndex(where: {$0.x == highlight.x}) ?? 0 //获取索引
//
//        /// 折线选中圆修改颜色
//        var circleColors = [UIColor]()
//        for _ in 0..<lineValues.count {
//            circleColors.append(.white)
//        }
//        lchartDataSet.circleColors = circleColors
//        lchartDataSet.circleColors[index] = Colors.main
//        lchartDataSet.circleHoleColor = Colors.chartBarH
//
//        //重新渲染表格
//        chartView.data?.notifyDataChanged()
//        chartView.notifyDataSetChanged()
    }
//
//    func chartValueNothingSelected(_ chartView: ChartViewBase) {
//        // 还原所有点的颜色
//        var lchartDataSet = LineChartDataSet()
//        lchartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
//        let lineValues = lchartDataSet.entries
//        /// 取消时重置折线选中圆修改颜色
//        var circleColors = [UIColor]()
//        for _ in 0..<lineValues.count {
//            circleColors.append(.white)
//        }
//        lchartDataSet.circleColors = circleColors
//
//        // 重新渲染表格
//        chartView.data?.notifyDataChanged()
//        chartView.notifyDataSetChanged()
//    }
}

// MARK: - other classes
