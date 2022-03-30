//
//  ViewReusePool.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2022/3/30.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit

// MARK: - global var and methods
class ReusePoolQueue {
    fileprivate var usedUsedQueue: NSMutableSet = []
    fileprivate var waitUsedQueue: NSMutableSet = []
}

// MARK: - main class
protocol ViewReusePool {
    associatedtype T
    var reuseQueue: ReusePoolQueue { get set }
    func dequeueReusableView() -> T?
    func addReuseView(_ view: T)
    func reset()
}

// MARK: - private mothods
extension ViewReusePool {

    func dequeueReusableView() -> T? {
        if let view = reuseQueue.waitUsedQueue.anyObject() as? T {
            reuseQueue.waitUsedQueue.remove(view)
            reuseQueue.usedUsedQueue.add(view)
            return view
        }
        return nil
    }

    func addReuseView(_ view: T) {
        reuseQueue.usedUsedQueue.add(view)
    }

    func reset() {
        while (reuseQueue.usedUsedQueue.anyObject() != nil) {
            if let view = reuseQueue.usedUsedQueue.anyObject() {
                reuseQueue.usedUsedQueue.remove(view)
                reuseQueue.waitUsedQueue.add(view)
            }
        }
    }
}
