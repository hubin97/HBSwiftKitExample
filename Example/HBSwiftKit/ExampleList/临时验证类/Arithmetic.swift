//
//  Arithmetic.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2022/4/11.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import MapKit
import PromiseKit

// MARK: - 字符串反转
// swift: string.reversed()
func strReversed(_ str: String) -> String {
    var rstrs = [String]()
    for idx in 0..<str.count {
        let index = str.count - idx - 1
        let char = str[index]
        rstrs.append(char)
    }
    return rstrs.joined()
}

// MARK: - 单链表反转
// https://www.jianshu.com/p/cf962aeff643
class Node {
    var data: Int?
    var next: Node?
    init() {}
    convenience init(data: Int, next: Node?) {
        self.init()
        self.data = data
        self.next = next
    }
}

func createNodeList(_ n: Int) -> [Node] {
    var nodes = [Node]()
    var last: Node?
    for idx in 0..<n {
        let node = Node(data: idx + 1, next: last)
        nodes.append(node)
        last = node
    }
    return nodes
}

func printNodeList(_ nodes: [Node]) {
    printLog(">>")
    nodes.forEach({ print("\($0.data ?? 0)") })
}

func reversedNodeList(_ nodes: [Node]) -> [Node] {
    var tmpNodes = [Node]()
    var last: Node?
    for idx in 0..<nodes.count {
        let node = nodes[nodes.count - 1 - idx]
        node.next = last
        tmpNodes.append(node)
        last = node
    }
    return tmpNodes
}

// MARK: - 有序数组合并
func combineArray(with arr1: [Int], and arr2: [Int]) -> [Int] {

    var list = [Int]()
    let list1 = arr1 //.sorted()
    let list2 = arr2 //.sorted()
    if let last1 = list1.last, let first2 = list2.first, first2 > last1 {
        list.append(contentsOf: list1)
        list.append(contentsOf: list2)
        return list
    }
    if let last2 = list2.last, let first1 = list1.first, first1 > last2 {
        list.append(contentsOf: list2)
        list.append(contentsOf: list1)
        return list
    }

    var i1 = 0
    var i2 = 0
    while i1 < list1.count && i2 < list2.count {
        if list1[i1] < list2[i2] {
            list.append(list1[i1])
            i1 += 1
        } else {
            list.append(list2[i2])
            i2 += 1
        }
    }

    while i1 < list1.count {
        list.append(list1[i1])
        i1 += 1
    }

    while i2 < list2.count {
        list.append(list2[i2])
        i2 += 1
    }
    return list
}

// MARK: - * Hash
// 在一个字符串中找到第一个只出现一次的字符. 如 "abaccde", // b
func firstOnceChar(with str: String) -> Character? {
    var hashMap = [Int]()
    for _ in 0..<256 {
        hashMap.append(0)
    }
    for ch in str {
        if let idx = ch.asciiValue {
            hashMap[Int(idx)] += 1
        }
    }
    return str.first(where: { hashMap[Int($0.asciiValue ?? 0)] == 1 })
}

// MARK: 求无序数组的中位数
// 1. 先排序再求中位数
// 2. 快排
//func findMedian(_ arr: [Int]) -> Int {
//    // 区分 奇数/ 偶数
////    //方案1
////    let list = arr.sorted()
////    let count = list.count
////    return count % 2 == 0 ? (list[count/2 - 1] + list[count/2])/2: list[count/2]
//    guard arr.count > 1 else {
//        return arr.last!
//    }
//
//    // 方案2
//    let low = 0
//    let high = arr.count - 1
//    let mid = arr[arr.count/2]
//
//    var listl = [Int]()
//    var listr = [Int]()
//
//    while low < high {
//
//    }
//}

//func findMedian<T: Comparable>(_ arr: [T]) -> T {
//    guard arr.count > 1 else { return arr[0] }
//    let pivot = arr[arr.count/2]
//    let less = arr.filter { $0 < pivot }
//    let equal = arr.filter { $0 == pivot }
//    let greater = arr.filter { $0 > pivot }
//
//}

func quicksort<T: Comparable>(_ a: [T]) -> [T] {
    guard a.count > 1 else { return a }

    let pivot = a[a.count/2]
    let less = a.filter { $0 < pivot }
    let equal = a.filter { $0 == pivot }
    let greater = a.filter { $0 > pivot }

    return quicksort(less) + equal + quicksort(greater)
}



func quickSort(_ arr: inout [Int], _ left: Int?, _ right: Int?) -> [Int] {
    let len = arr.count
    var partitionIndex = 0
    let left = left ?? 0
    let right = right ?? len - 1
    if (left < right) {
        partitionIndex = partition(&arr, left, right)
        quickSort(&arr, left, partitionIndex - 1)
        quickSort(&arr, partitionIndex + 1, right)
    }
    return arr
}

func partition(_ arr: inout [Int], _ left: Int, _ right: Int) -> Int {     // 分区操作
    let pivot = left // 设定基准值（pivot）
    var index = pivot + 1
    for i in index...right where arr[i] < arr[pivot] {
        swap(&arr, i, index)
        index += 1
    }
    swap(&arr, pivot, index - 1)
    return index - 1
}

func swap(_ arr: inout [Int], _ i: Int, _ j: Int) {
    let temp = arr[i]
    arr[i] = arr[j]
    arr[j] = temp
}
