//
//  Leetcode.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2022/4/19.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation

class Solution {
//    func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
//        for i in 0..<nums.count - 1 {
//            for j in (i + 1)..<nums.count where nums[i] + nums[j] == target {
//                return [i, j]
//            }
//        }
//        return []
//    }

//    func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
//        for i in 0..<nums.count - 1 {
//            let value = target - nums[i]
//            if let j = nums.drop(while: { $0 == i}).firstIndex(of: value), nums.contains(value) {
//                return [i, j]
//            }
//        }
//        return []
//    }

    func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
        var res = [Int]()
        var dict = [Int: Int]()
        for i in 0 ..< nums.count {
            let other = target - nums[i]
            if dict.keys.contains(other) {
                res.append(i)
                res.append(dict[other]!)
                return res
            }
            dict[nums[i]] = i
        }
        return res
    }

//    // dir\n\tsubdir1\n\t\tfile1.ext\n\t\tsubsubdir1\n\tsubdir2\n\t\tsubsubdir2\n\t\t\tfile2.ext
//    func lengthLongestPath(_ input: String) -> Int {
//        //input.forEach({ print($0) })
//        //input.filter({ $0 == Character.init("\t") })
//        let mkdirs = input.components(separatedBy: "\n\t")
//        if mkdirs.count > 0 {
//
//        } else {
//            let omkdirs = input.components(separatedBy: "\n")
//            if omkdirs.count == 0 && input {
//                return 0
//            }
//        }
//        return 0
//    }

    ///# 461. 汉明距离
    func hammingDistance(_ x: Int, _ y: Int) -> Int {
        //return (x ^ y).nonzeroBitCount
        return String(x ^ y, radix: 2).filter({ $0 == "1"}).count
    }

    ///#228. 汇总区间
    func summaryRanges(_ nums: [Int]) -> [String] {
        var ranges = [[Int]]()
        var metas = [Int]()
        for idx in 0..<nums.count {
            let last = (idx > 0) ? nums[idx - 1] : nil
            let value = nums[idx]
            if let lastValue = last {
                if value - lastValue > 1 {
                    ranges.append(metas)
                    metas.removeAll()
                }
            }
            metas.append(value)
            if idx == nums.count - 1 && metas.count > 0 {
                ranges.append(metas)
            }
        }
        return ranges.map({ $0.count == 1 ? "\($0.last!)": "\($0.first!)->\($0.last!)" })
    }

    // [[0,1],[6,8],[0,2],[5,6],[0,4],[0,3],[6,7],[1,3],[4,7],[1,4],[2,5],[2,6],[3,4],[4,5],[5,7],[6,9]], time = 9
    ///# 1024. 视频拼接
    func videoStitching(_ clips: [[Int]], _ time: Int) -> Int {
//        let first_lasts = clips.filter({ $0.first == 0 }).map({ $0.last! })
//        let last_firsts = clips.filter({ $0.last == time }).map({ $0.first! })
//        guard first_lasts.count > 0 && last_firsts.count > 0 else { return -1 }
        //let medians = clips.filter({ first_lasts.contains($0.first!) })
        var dp = [Int]()
        for i in 0...time {
            dp.append(i == 0 ? 0: Int.max - 1)
        }
        for i in 1...time {
            for j in 0..<clips.count {
                if clips[j][0] < i && i <= clips[j][1] {
                    dp[i] = min(dp[i], dp[clips[j][0]] + 1)
                }
            }
        }
        return (dp[time] == Int.max - 1) ? -1: dp[time]
    }
}
