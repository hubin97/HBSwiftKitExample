//
//  Wto_CombinedChart.swift
//  test
//
//  Created by hubin.h@wingto.cn on 2020/9/7.
//  Copyright © 2020 WingTo. All rights reserved.

import Foundation
import Charts

/**
  https://www.cnblogs.com/qqcc1388/tag/charts/
  comb: https://www.jianshu.com/p/e531d97dbb62
  drawMarkers设置 https://www.cnblogs.com/qqcc1388/p/11169523.html
  iOS使用Charts框架绘制—柱形图 https://www.jianshu.com/p/5f777671e9e4
 */
/**
 /// BarChart添加渐变色备忘 (垂直柱状图)BarChartRenderer.swift/ (水平柱状图)HorizontalBarChartRenderer.swift
 // 调用使用 func setColors(_ colors: NSUIColor...)
 //            if !isSingleColor
 //            {
 //                // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
 //                context.setFillColor(dataSet.color(atIndex: j).cgColor)
 //            }
 //
 //            context.fill(barRect)
 if !isSingleColor
 {
 let fillColors = [dataSet.color(atIndex: 0).cgColor, dataSet.color(atIndex: 1).cgColor]
 let locations:[CGFloat] = [0.0, 1.0]
 
 context.saveGState()
 context.clip(to: barRect)
 let gradient:CGGradient
 let colorspace:CGColorSpace
 colorspace = CGColorSpaceCreateDeviceRGB()
 
 gradient = CGGradient(colorsSpace: colorspace, colors: fillColors as CFArray, locations: locations)!
 
 //Vertical Gradient
 let startPoint:CGPoint = CGPoint(x: 0.0, y: viewPortHandler.contentBottom)
 let endPoint:CGPoint = CGPoint(x: 0.0, y: viewPortHandler.contentTop)
 
 context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .init(rawValue: 0))
 context.restoreGState()
 } else {
 context.fill(barRect)
 }
 */

// MARK: - main class
class Wto_CombinedChart: UIView {

    /// 网格虚线颜色
    var gridColor: UIColor = .brown
    var textColor: UIColor = .gray
    var selCircleColor: UIColor = .systemYellow
    var markerBgColor: UIColor = .groupTableViewBackground //UIColor(white: 0, alpha: 0.04)
    var markerTextColor: UIColor = .black
    var showMyLegend = false // 自定义图例
    /// 水平分块 默认12
    var xAxisCount: Int = 12
    /// 垂直分块 默认5
    var yAxisCount: Int = 5

    var mlineSet: LineChartDataSet?
    var mbarSet: BarChartDataSet?
    var markerTitlePrefix: String? // 气泡标签前缀
    var xAxisValueFormatter: ChartAxisFormatter? {
        didSet {
            let xAxis = chartView.xAxis
            xAxis.valueFormatter = xAxisValueFormatter
        }
    }
    lazy var marker: BalloonMarker = {
        let marker = BalloonMarker(color: markerBgColor,
                                   font: .systemFont(ofSize: 12),
                                   textColor: markerTextColor,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.minimumSize = CGSize(width: 100, height: 60)
        marker.chartView = chartView
        self.chartView.marker = marker
        return marker
    }()
    lazy var chartView: CombinedChartView = {
        let chartView = CombinedChartView.init(frame: self.bounds)
        // 注意 数组前后关联图层前后
        chartView.drawOrder = [DrawOrder.bar.rawValue, DrawOrder.line.rawValue]
        chartView.pinchZoomEnabled = false  // 是否开启捏合手势
        chartView.setScaleEnabled(false) // 是否支持拉伸
        chartView.chartDescription?.enabled = false ///
        chartView.setExtraOffsets(left: 20, top: 20, right: 20, bottom: 10)
        // chartView.drawBarShadowEnabled = true  // 灰色补全空白bar
        chartView.delegate = self
        return chartView
    }()

    // UIScreen.main.bounds.width * 350
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(chartView)
        self.updateLayout()
    }

    // updateLayout
    func updateLayout() {
        setLegend()
        setXYAxis()
    }
    func setLegend() {
        guard showMyLegend == false else {
            self.chartView.legend.enabled = false
            return
        }
        /// 图例位置
        let l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .line
        l.formSize = 9
        l.textColor = textColor
        l.font = UIFont(name: "HelveticaNeue-Light", size: 12)!
        l.xEntrySpace = 4
    }
    func setXYAxis() {
        /// X轴
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom

        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true // x轴线
        xAxis.axisLineColor = .clear // 轴线的颜色 和宽度
        xAxis.axisLineWidth = 0.5
        xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        xAxis.labelTextColor = textColor
        //xAxis.labelRotationAngle = 30 // 文字倾斜角度
        xAxis.setLabelCount(xAxisCount, force: false)  // 刻度标识12段

        /// 左Y轴
        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .outsideChart // 刻度标签显示位置, 内部/外边
        leftAxis.drawGridLinesEnabled = true // 绘制网格线
        leftAxis.drawAxisLineEnabled = false  // 是否显示轴线
        leftAxis.drawLabelsEnabled = false // 是否显示标签
        leftAxis.drawZeroLineEnabled = true  //从0开始绘制
        leftAxis.gridLineDashLengths = [4.0, 4.0]  // 虚线网格
        //leftAxis.axisLineDashPhase = 5
        leftAxis.gridColor = gridColor
        leftAxis.gridAntialiasEnabled = true  //开启抗锯齿
        //leftAxis.axisLineColor = .lightGray  //
        //leftAxis.axisLineWidth = 0.5
        leftAxis.labelFont = UIFont.systemFont(ofSize: 10)
        leftAxis.labelTextColor = textColor

        leftAxis.axisMinimum = 0 // 设置y轴由0开始
        //leftAxis.axisMaximum = 100 // 最大值（不设置会根据数据自动设置）
        leftAxis.setLabelCount(yAxisCount, force: true) // 分几段

        /// 右Y轴  // 尽管不使用,但是也必须设置屏蔽
        let rightAxis = chartView.rightAxis
        rightAxis.labelPosition = .outsideChart
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawAxisLineEnabled = false  // 是否显示轴线
        //rightAxis.axisLineColor = .lightGray
        //rightAxis.axisLineWidth = 0.5
        rightAxis.drawLabelsEnabled = false // 是否显示标签
        rightAxis.labelFont = UIFont.systemFont(ofSize: 10)
        rightAxis.labelTextColor = textColor
        //rightAxis.axisMinimum = 0
        //rightAxis.axisMaximum = 100 // 最大值（不设置会根据数据自动设置）
        rightAxis.setLabelCount(yAxisCount, force: true) // 分几段
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - private mothods
extension Wto_CombinedChart {
    open func setChartData(lineSet: LineChartDataSet, barSet: BarChartDataSet) {
        self.mlineSet = lineSet
        self.mbarSet = barSet
        let data = CombinedChartData()
        data.lineData = generateLineData(lineSet: lineSet)
        data.barData = generateBarData(barSet: barSet)
        // 调整bar两侧的边距
        chartView.xAxis.axisMinimum = data.xMin - 0.2
        chartView.xAxis.axisMaximum = data.xMax + 0.2
        chartView.data = data
        chartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5) // 开启动画
    }

    fileprivate func generateLineData(lineSet: LineChartDataSet) -> LineChartData {
        let set = LineChartDataSet(entries: lineSet.entries, label: lineSet.label)
        set.setColor(UIColor.red) // 线条颜色
        set.lineWidth = 1.5
        set.drawCirclesEnabled = true  // 是否有转折点
        set.drawCircleHoleEnabled = true // 是否有空心
        set.setCircleColor(.red)
        set.circleHoleColor = .white
        set.circleRadius = 3 //圆点外圆半径
        set.circleHoleRadius = 2  // 圆点内圆半径
        set.mode = .horizontalBezier   // 平滑曲线
        set.drawValuesEnabled = false  // 是否显示数值
        set.valueFont = .systemFont(ofSize: 12)
        set.valueTextColor = textColor

        set.axisDependency = .left // 必须共用 //根据左y轴数据显示
        set.drawFilledEnabled = true

        let colors = [HEXA(hexValue: 0xEF9493, a: 0.24).cgColor, HEXA(hexValue: 0xE65C5B, a: 0.37).cgColor]
        let cggradient = CGGradient.init(colorsSpace: nil, colors: colors as CFArray, locations: nil)
        set.fill = Fill.fillWithLinearGradient(cggradient!, angle: 90.0)
        //set.fillColor = .red //
        set.fillAlpha = 1.0 // 阴影透明度
        set.highlightEnabled = false  /// 禁用折线点击事件

        /// 十字线
        set.highlightEnabled = false //不启用十字线
        set.highlightColor = .blue
        set.highlightLineDashLengths = [4, 2]
        set.drawVerticalHighlightIndicatorEnabled = true
        set.drawHorizontalHighlightIndicatorEnabled = false
        return LineChartData(dataSet: set)
    }

    fileprivate func generateBarData(barSet: BarChartDataSet) -> BarChartData {

        let set = BarChartDataSet(entries: barSet.entries, label: barSet.label)
        set.axisDependency = .left  // 依赖左y轴数据
        // set.setColor(UIColor.red.withAlphaComponent(0.5))
        set.drawValuesEnabled = false // 是否显示数据
        set.valueTextColor = textColor
        set.valueFont = .systemFont(ofSize: 12)
        set.highlightColor = .red
        // set.highlightEnabled = false  // 点击选中柱形图是否有高亮效果，（双击空白处取消选中）
        /// 📊条形图渐变 需要修改库文件 BarChartRenderer.swift -> !isSingleColor -> 渐变色修改
        set.setColors(HEX(hexValue: 0xFFEAEA), HEX(hexValue: 0xD80200))

        let data = BarChartData(dataSet: set)
        data.barWidth = 0.40
        return data
    }
}

// MARK: - delegate or data source
extension Wto_CombinedChart: ChartViewDelegate {
    // 点选
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // Line
        //将选中的数据点的颜色改成黄色
        var lchartDataSet = LineChartDataSet()
        lchartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        let lineValues = lchartDataSet.entries
        let index = lineValues.firstIndex(where: {$0.x == highlight.x}) ?? 0 //获取索引

        // Bar
        var bchartDataSet = BarChartDataSet()
        bchartDataSet = (chartView.data?.dataSets[1] as? BarChartDataSet)!
        let barValues = bchartDataSet.entries

        let linePoint: ChartDataEntry = lineValues[index]
        //print("line value: \(linePoint)")

        let barPoint: ChartDataEntry = barValues[index]
        //print("bar value: \(barPoint)")

        /// 折线选中圆修改颜色
        var circleColors = [UIColor]()
        for _ in 0..<lineValues.count {
            circleColors.append(.red)
        }
        lchartDataSet.circleColors = circleColors
        lchartDataSet.circleColors[index] = selCircleColor

        // self.mlineSet = lineSet self.mbarSet = barSet
        self.marker.setLabel("\(markerTitlePrefix ?? "") \(self.xAxisValueFormatter?.titles[index] ?? "") \n \(self.mlineSet?.label ?? "")：\(linePoint.y)kW·h \n \(self.mbarSet?.label ?? "")：\(barPoint.y)kW·h")

        //重新渲染表格
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }

    // 取消选中
    func chartValueNothingSelected(_ chartView: ChartViewBase) {

        //还原所有点的颜色
        var lchartDataSet = LineChartDataSet()
        lchartDataSet = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        let lineValues = lchartDataSet.entries
        /// 取消时重置折线选中圆修改颜色
        var circleColors = [UIColor]()
        for _ in 0..<lineValues.count {
            circleColors.append(.red)
        }
        lchartDataSet.circleColors = circleColors

        //重新渲染表格
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }
}

// MARK: - other classes
/// 自定义字串格式轴标签
@objc(BarChartFormatter)
public class ChartAxisFormatter: NSObject, IAxisValueFormatter {
    var titles = [String]()
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return titles[Int(value)]
    }

    public func setValues(values: [String]) {
        self.titles = values
    }
}
