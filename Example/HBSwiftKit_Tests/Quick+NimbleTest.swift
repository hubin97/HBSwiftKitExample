//
//  Quick+NimbleTest.swift
//  HBSwiftKit_Tests
//
//  Created by design on 2021/4/14.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import HBSwiftKit

class Quick_NimbleTest: QuickSpec {

    override func spec() {
        
        fdescribe("test name") {
            it("should print correct test data") {
                
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
                expect(10.0).to(beGreaterThan(10))
            }
        }
    }
}
