//
//  Navigator.swift
//  Petcozy
//
//  Created by hubin.h on 2024/5/28.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import AVKit

/// 用于视图控制器导航
/// 推荐使用`枚举`来实现
public protocol SceneProvider {
    /// 获取视图控制器
    var getSegue: UIViewController? { get }
}

// MARK: - 路由协议
public protocol Navigatable {
    var navigator: Navigator! { get set }
}

// MARK: - Navigator
public class Navigator {
    public static var `default` = Navigator()
}

extension Navigator {
    
    public enum Transition {
        case root(in: UIWindow)
        case navigation
        case modal(type: UIModalPresentationStyle)
        case detail
        case alert
        case custom
    }
    
    public func pop(sender: UIViewController?, toRoot: Bool = false) {
        if toRoot {
            sender?.navigationController?.popToRootViewController(animated: true)
        } else {
            sender?.navigationController?.popViewController(animated: true)
        }
    }
    
    public func dismiss(sender: UIViewController?) {
        sender?.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @discardableResult
    public func show(provider: SceneProvider, sender: UIViewController?, transition: Transition = .navigation) -> UIViewController? {
        guard let target = provider.getSegue else { return nil }
        self.show(target: target, sender: sender, transition: transition)
        return target
    }
    
    private func show(target: UIViewController, sender: UIViewController?, transition: Transition) {
        switch transition {
        case .root(in: let window):
            window.rootViewController = target
            return
        case .custom: return
        default: break
        }
        
        guard let sender = sender else {
            fatalError("You need to pass in a sender for .navigation or .modal transitions")
        }
        
        if let nav = sender as? UINavigationController {
            nav.pushViewController(target, animated: false)
            return
        }
        
        switch transition {
        case .navigation:
            if let nav = sender.navigationController {
                nav.pushViewController(target, animated: true)
            }
        case .modal(let type):
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                nav.modalPresentationStyle = type
                sender.present(nav, animated: true, completion: nil)
            }
        case .detail:
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.showDetailViewController(nav, sender: nil)
            }
        case .alert:
            DispatchQueue.main.async {
                sender.present(target, animated: true, completion: nil)
            }
        default: break
        }
    }
}
