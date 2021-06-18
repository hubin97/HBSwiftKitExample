//
//  TableViewDragInsertAble.swift
//  WingToSmart
//
//  Created by Hubin_Huang on 2021/6/18.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import AudioToolbox

/**
 iOS11以下版本,实际上拖拽的不是cell,而是cell的快照imageView.并且同时将cell隐藏,当拖拽手势结束时,通过moveRow方法调换cell位置,进行数据修改.并且将imageView删除再将cell展示出来,就实现了拖拽动画.
 */
//MARK: 兼容iOS11以下版本插入排序
protocol TableViewDragInsertAble: NSObject {
    
    /// 指定应用操作的列表
    var listView: UITableView { get set}
    /// 指定任意类型数据源, 可使用dataTypeTransfer转换内部元素遍历
    var dataSource: [Any]? { get set }
    
    //MARK: 辅助字段, 外部无需关注和实现
    /// 手势储存point,保证有两个,为初始点和结束点
    var touchPoints: [CGPoint]? { get set }
    /// 手势选中cell.index
    var sourceIndexPath: IndexPath? { get set }
    /// 将手势选中cell以image形式表现
    var cellImageView: UIImageView? { get set }
    
    /** 协议不兼容@objc, 外部委托类实现两个方法
     func addLongPress(for view: UIView) {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(dragGesture))
        if view.gestureRecognizers?.filter({ $0 is UILongPressGestureRecognizer }).count ?? 0 == 0 {
            view.addGestureRecognizer(longPress)
        }
     }
     @objc func dragGesture(_ rec: UILongPressGestureRecognizer) {
        longPressGesture(rec)
     }
     */
    /// 为cell或其上的视图添加长按手势
    func addLongPress(for view: UIView)

    /**
     // 转换类型, 方便遍历属性操作数据
     dataTypeTransfer(AeraManagerMeta.self)?.forEach({
         $0.isEditing = isListEditing
         $0.isSelected = false
     })
     */
    /// 数据源内部元素类型转换
    func dataTypeTransfer<T: Any>(_ with: T.Type) -> [T]?
}

//MARK: - private mothods
extension TableViewDragInsertAble {
    
    /// 数据源内部元素类型转换
    func dataTypeTransfer<T: Any>(_ with: T.Type) -> [T]? {
        return (dataSource as? [T])
    }
    
    /// 手势方法
    func longPressGesture(_ recognise: UILongPressGestureRecognizer) {
        let currentPoint: CGPoint = recognise.location(in: listView)
        let currentIndexPath = listView.indexPathForRow(at: currentPoint)
        guard let indexPath = currentIndexPath else {
            removeCellImageView()
            return
        }
        
        guard indexPath.row < dataSource?.count ?? 0 else {
            removeCellImageView()
            return
        }
        
        switch recognise.state {
        case .began:
            longPressGestureBegan(recognise)
        case .changed:
            longPressGestureChanged(recognise)
        default:
            /// 手势结束状态; 清空保存的手势点
            self.touchPoints?.removeAll()
            /// 将隐藏的cell展示
            if let cell = listView.cellForRow(at: sourceIndexPath! ) {
                cell.isHidden = false
            }
            removeCellImageView()
        }
    }
    
    /// 长按开始状态调用方法
    private func longPressGestureBegan(_ recognise: UILongPressGestureRecognizer) {
        /// 获取长按手势触发时的接触点
        let currentPoint: CGPoint = recognise.location(in: listView)
        /// 根据手势初始点获取需要拖拽的cell.indexPath
        guard let currentIndexPath = listView.indexPathForRow(at: currentPoint),
              let currentCell = listView.cellForRow(at: currentIndexPath ) else { return }
        /// 将拖拽cell.index储存
        sourceIndexPath = currentIndexPath
        /// 获取拖拽cell快照
        cellImageView = UIImageView.init(image: currentCell.interceptView())
        /// 将快照加入到tableView.把拖拽cell覆盖
        if let cellImageView = cellImageView {
            cellImageView.frame = currentCell.frame
            listView.addSubview(cellImageView)
        }
        /// 将选中cell隐藏
        currentCell.isHidden = true
        impactFeedBack()
    }
    
    /// 拖拽手势过程中方法,核心方法,实现拖拽动画和数据的更新
    private func longPressGestureChanged(_ recognise: UILongPressGestureRecognizer) {
        let selectedPoint: CGPoint = recognise.location(in: listView)
        let selectedIndexPath = listView.indexPathForRow(at: selectedPoint)
        /// 将手势的点加入touchPoints并保证其内有两个点,即一个初始点,一个结束点,实现cell快照imageView从初始点到结束点的移动动画
        self.touchPoints?.append(selectedPoint)
        if let points = self.touchPoints?.count, points > 2 {
            self.touchPoints?.remove(at: 0)
        }
        guard let cellImageView = cellImageView else { return }
        var center = cellImageView.center
        /// 快照center.y值直接移动到手势点Y,可以提醒用户cell已经进入了拖拽状态
        center.y = selectedPoint.y
        // 快照x值随触摸点x值改变量移动,保证用户体验
        // 这里屏蔽x轴移动
//        let nPoint = self.touchPoints?.first
//        let pPoint = self.touchPoints?.last
//        let moveX = pPoint!.x - nPoint!.x
//        center.x += moveX
        cellImageView.center = center
        guard selectedIndexPath != nil else { return }
        /// 如果手势当前index不同于拖拽cell,则需要moveRow,实现tableView上非拖拽cell的动画,这里还要实现数据源的重置,保证拖拽手势后tableView能正确的展示
        if selectedIndexPath != sourceIndexPath {
            listView.beginUpdates()
            /// 线程锁
            objc_sync_enter(self)
            
            /// 先更新tableView数据源
            if let sourceIndexPath = sourceIndexPath, let cellModel = dataSource?[sourceIndexPath.row] {
                dataSource?.remove(at: sourceIndexPath.row)
                if selectedIndexPath!.row < dataSource?.count ?? 0 {
                    dataSource?.insert(cellModel, at: selectedIndexPath!.row)
                } else {
                    dataSource?.append(cellModel)
                }
            }
            // 音效播放
            impactFeedBack()
            objc_sync_exit(self)
            /// 调用moveRow方法,修改被隐藏的选中cell位置,保证选中cell和快照imageView在同一个row,实现动画效果
            listView.moveRow(at: sourceIndexPath!, to: selectedIndexPath!)
            listView.endUpdates()
            sourceIndexPath = selectedIndexPath
        }
    }
    
    /// 将生成的cell快照删除
    private func removeCellImageView() {
        self.cellImageView?.removeFromSuperview()
        listView.reloadData()
    }
    
    /// 震动反馈
    private func impactFeedBack() {
        if #available(iOS 10.0, *) {
            let y = UIImpactFeedbackGenerator.init(style: .heavy)
            y.prepare()
            y.impactOccurred()
        } else {
            AudioServicesPlaySystemSound(1519)
        }
    }
}
