////
////  YTTabController.swift
////  YTTabBar
////
////  Created by Hubin_Huang on 2021/5/10.
////  Copyright © 2020 Wingto. All rights reserved.
//
//import UIKit
//import Foundation
//
////MARK: - main class
//open class YTTabController: UIViewController {
//
//    public var tabBar: YTTabBar?
//    public var viewControllers: [UIViewController]?
//    public var selectedIndex: Int = 0
//    public var selectedViewController: UIViewController?
//
//    /// 便捷初始化
//    /// - Parameters:
//    ///   - tabBar: tabBar对象
//    ///   - viewControllers: vc数组
//    ///   - selectedIndex: 默认选中标签页 0
//    public convenience init(tabBar: YTTabBar, viewControllers: [UIViewController], selectedIndex: Int = 0) {
//        self.init()
//        guard let items = tabBar.tabBarItems, items.count > 0 && viewControllers.count > 0 else { return }
//        assert(items.count == viewControllers.count, "标签页和控制器数目不一致")
//        self.tabBar = tabBar
//        self.viewControllers = viewControllers
//        self.selectedIndex = selectedIndex
//        self.selectedViewController = viewControllers[selectedIndex]
//        self.addTabBar()
//    }
//
//    deinit {
//        print("YTTabController deinit")
//    }
//
//    open override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//
//    //MARK: 事件点击回调
//    open func tabBarTapAction(idx: Int, didSelect viewController: UIViewController) {
//
//    }
//
//    //MARK: 自定义过渡动画实现, 需要重写此方法
//    open func transitionViewController(fromVc: UIViewController, toVc: UIViewController, duration: TimeInterval = 0.2, options: UIView.AnimationOptions = .curveLinear, animations: (() -> Void)? = nil) {
//        //print("from:\(NSStringFromClass(oldVc.classForCoder)) to: \(NSStringFromClass(newVc.classForCoder))")
//        guard let tabBar = self.tabBar, fromVc != toVc else { return }
//        DispatchQueue.main.async {
//            self.selectedViewController?.beginAppearanceTransition(true, animated: true)
//            self.addChild(toVc)
//            self.view.addSubview(toVc.view)
//            self.transition(from: fromVc, to: toVc, duration: duration, options: options, animations: animations) { (finish) in
//                toVc.didMove(toParent: self)
//                fromVc.willMove(toParent: nil)
//                fromVc.removeFromParent()
//                fromVc.view.removeFromSuperview()
//                self.view.bringSubviewToFront(tabBar)
//            }
//            self.selectedViewController?.endAppearanceTransition()
//        }
//    }
//}
//
////MARK: - private mothods
//extension YTTabController {
//
//    func addTabBar() {
//        guard let tabBar = self.tabBar, let vcs = self.viewControllers else { return }
//        guard selectedIndex >= 0 && selectedIndex < vcs.count else { return }
//        defer {
//            view.addSubview(tabBar)
//        }
//        for idx in 0..<vcs.count {
//            let vc = vcs[idx]
//            if idx == selectedIndex {
//                self.addChild(vc)
//                self.view.addSubview(vc.view)
//            }
//        }
//        tabBar.selectIdx(idx: selectedIndex)
//        tabBar.tapAction = {[weak self] (idx, model) in
//            guard let oldIdx = self?.selectedIndex else { return }
//            let fromVc = vcs[oldIdx]
//            let toVc = vcs[idx]
//            self?.transitionViewController(fromVc: fromVc, toVc: toVc)
//
//            self?.selectedIndex = idx
//            self?.selectedViewController = vcs[idx]
//            self?.setNeedsStatusBarAppearanceUpdate()
//            self?.tabBarTapAction(idx: idx, didSelect: vcs[idx])
//        }
//    }
//}
//
////MARK: - delegate
//// https://www.it610.com/article/1291616824613478400.htm
//extension YTTabController {
//
//    open override var preferredStatusBarStyle: UIStatusBarStyle {
//        get {
//            return selectedViewController?.preferredStatusBarStyle ?? .default
//        }
//    }
//
//    open override var shouldAutorotate: Bool {
//        get {
//            return selectedViewController?.shouldAutorotate ?? false
//        }
//    }
//
//    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        get {
//            return selectedViewController?.supportedInterfaceOrientations ?? .portrait
//        }
//    }
//
//    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        let duration = coordinator.transitionDuration
//        if size.width > size.height {
//            //print("横屏")
//            self.tabBar?.updateLayout(duration: duration, isPortrait: false)
//        } else {
//            //print("竖屏")
//            self.tabBar?.updateLayout(duration: duration, isPortrait: true)
//        }
//    }
//}
