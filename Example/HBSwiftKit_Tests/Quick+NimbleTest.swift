//
//  Quick+NimbleTest.swift
//  HBSwiftKit_Tests
//
//  Created by design on 2021/4/14.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Quick
import Nimble

@testable import HBSwiftKit_Example
@testable import HBSwiftKit

class Quick_NimbleTest2: QuickSpec {
    
    override func spec() {
        
        fdescribe("test name") {
            it("should print correct test data") {
                AuthStatus.locationServices { (status) in
                    print("定位权限\(status ? "on": "off")")
                }
                
                
                
                // https://github.com/Tliens/SpeedySwift
                struct reqHead {
                    let magicl: UInt8 = 0xFF  // 1  0xff
                    let magic2: UInt8 = 0x55  // 1  0x55
                    let msg_type: Int16 = 3 // 2
                    let msg_len: Int16 = 12 // 2
                    let res_code: Int16 = 0 // 2
                    let reserv: Int32 = 0   // 4
                    
                }
        //        var car = "Benz"
        //        let closure = { [car] in
        //          print("I drive \(car)")
        //        }
        //        car = "Tesla"
        //        closure()
                
                let head = reqHead()
                //head.magicl
                print("head:\(head)")
            }
        }
    }
}

class Quick_NimbleTest: QuickSpec {

    override func spec() {
        
        fdescribe("test name") {
            it("should print correct test data") {
                
                let color1 = UIColor.init(hexStr: "#57CBFF")
                let color2 = UIColor.init(hexStr: "0x57CBFF")
                let color3 = UIColor.init(hexStr: "0X57CBFF")

                
                let string1 = "ａｂｃｄｅｆｇ，。"
                let string2 = "abcdefg,."
                let str1 = string1.fullwidthToHalfwidth()
                let str2 = string2.halfwidthToFullwidth()
                print("str1:\(str1)\nstr2:\(str2)")
                // string
                expect(str1).to(equal(string2))
                expect("山河".toPinyin()).to(equal("shan he"))
                expect("山河".toPYHead()).to(equal("SH"))
                
                //expect("ａｂｃｄｅｆｇ，。".fullwidthToHalfwidth())
                //expect(10.0).to(beGreaterThan(10))
                
                ThemeMode.light.setColors(bind: ["#000", "#010", "#001"])
                ThemeMode.dark.setColors(bind: ["#100", "#110", "#111"])
                //ThemeMode.main.setColors(bind: ["#100", "#111"])

                print(ThemeMode.dynamicColor(idx: 2))
                print(ThemeMode.dynamicColor(idx: 0))
                print(ThemeMode.dynamicColor(idx: 3))
                
                ThemeMode.mode = .dark
                print(ThemeMode.dynamicColor(idx: 2))
                print(ThemeMode.dynamicColor(idx: 0))
                print(ThemeMode.dynamicColor(idx: 3))
                
                //
                var dict: Dictionary<String, Any> = ["aaa": 123, "bbb": "444", "ccc": [555, 666, 777]]
                let data = dict.toData()
                let json = dict.toJSONString()
                let value = dict.value(forKey: "ccc")
                dict.setValue(["1": 1, "2": 2], forKey: "ddd")
                let value2 = dict.value(forKey: "ddd")

                print(data)
                print(json)
                print(value)
                print(value2)
            }
        }
    }
}
