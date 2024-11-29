//
//  BLEPriorityQueue.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/11/28.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

struct BLEPriorityQueue<Element: Comparable & Equatable> {

    // 排序优先级策略
    enum Order {
        case ascending
        case descending
    }
    
    private(set) var elements: [Element] = []
    private let order: Order?
    
    /// 队列是否为空
    var isEmpty: Bool {
        return elements.isEmpty
    }
    
    /// 当前大小
    var size: Int {
        return elements.count
    }
    
    /// 排序优先级策略
    init(order: Order? = nil) {
        self.order = order
    }
    
    /// 首元素
    func peek() -> Element? {
        elements.first
    }
    
    /// 入队方法：可指定插入位置
    mutating func enqueue(_ element: Element, at index: Int? = nil) {
        // 指定位置插入, 仅在未指定排序策略时有效
        if let index = index, order == nil {
            // 指定位置插入
            guard index >= 0 && index <= elements.count else {
                fatalError("Index out of bounds.")
            }
            elements.insert(element, at: index)
        } else {
            // 默认插入
            elements.append(element)
        }
        
        // 若指定排序策略，则排序
        if let order = order {
            elements.sort { (lhs, rhs) in
                order == .ascending ? (lhs < rhs) : (lhs > rhs)
            }
        }
    }
    
    /// 出队
    @discardableResult
    mutating func dequeue() -> Element? {
        guard let front = peek() else {
            return nil
        }
        remove(at: 0)
        return front
    }
    
    /// 判断元素是否存在
    func contains(_ element: Element) -> Bool {
        return elements.contains(element)
    }
    
    /// 移除指定位置的元素
    mutating func remove(_ element: Element) {
        for i in 0 ..< elements.count where elements[i] == element {
            remove(at: i)
        }
    }
    
    /// 移除指定位置的元素
    @discardableResult
    mutating func remove(at index: Int) -> Element {
        return elements.remove(at: index)
    }
    
    // MARK: - 排序辅助方法 (备用)
    private func binarySearchInsertIndex(for element: Element) -> Int {
        var low = 0
        var high = elements.count
        
        while low < high {
            let mid = (low + high) / 2
            let comparison = (order == .ascending) ? (elements[mid] < element) : (elements[mid] > element)
            if comparison {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low
    }
}

extension BLEPriorityQueue : CustomDebugStringConvertible {
    var debugDescription: String {
        elements.debugDescription
    }
}
