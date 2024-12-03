//
//  Extension+Math.swift
//  LuteBase
//
//  Created by hubin.h on 2024/11/7.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

extension Int {
    
    /// 计算最大公约数
    public static func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return a
    }

    /// 计算最小公倍数
    public static func lcm(_ a: Int, _ b: Int) -> Int {
        return abs(a * b) / gcd(a, b)
    }
}
