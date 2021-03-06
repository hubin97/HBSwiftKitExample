//
//  Quick+NimbleTest.swift
//  HBSwiftKit_Tests
//
//  Created by design on 2021/4/14.
//  Copyright © 2021 CocoaPods. All rights reserved.
//
//swift单元测试（八）总结 https://blog.csdn.net/lin1109221208/article/details/93486230?utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromMachineLearnPai2%7Edefault-8.control&dist_request_id=&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromMachineLearnPai2%7Edefault-8.control

import Quick
import Nimble

@testable import HBSwiftKit_Example
@testable import HBSwiftKit

//swiftClassFromString


class GlobalFuncTest: QuickSpec {
    override func spec() {
        fdescribe("GlobalFuncTest") {
            it("should print correct test data") {
                let vc1 = swiftClassFromString("ImageBrowerController")
                print("vc1:\(vc1)")
                if let vc1_1 = vc1 as? UIViewController.Type {
                    print("vc1_1:\(vc1_1)")
                }
                
                let vc2 = swiftClassFromString("SnapshotModel")
                print("vc2:\(vc2)")
                if let vc2_1 = vc2 as? UIViewController.Type {
                    print("vc2_1:\(vc2_1)")
                }
            }
        }
    }
}

class ImgExtensionTest: QuickSpec {
    override func spec() {
        fdescribe("ImgExtensionTest") {
            it("should print correct test data") {
                let img = UIImage.init(color: .brown)
                
            }
        }
    }
}

class QPathTest: QuickSpec {
    override func spec() {
        fdescribe("QPathTest") {
            it("should print correct test data") {
                _ = QPath.filePaths(documentPath ?? "")
                QPath.removeFile("")
                //        QPath.createFile(name: "111.txt", fileBaseUrl: URL.init(fileURLWithPath: documentPath ?? ""))
                //        QPath.createFile(name: "222.txt", fileBaseUrl: URL.init(fileURLWithPath: documentPath ?? ""))
                QPath.writingToFile(filePath: "\(documentPath ?? "")/222.txt", contents: "啦啦啦啦")
                QPath.writingToFile(filePath: "\(documentPath ?? "")/222.txt", contents: "\n哦哦哦哦")
                let dicPath = QPath.createDirectory(basePath: "\(documentPath ?? "")", dicName: "Img")
                QPath.createFile(filePath: "\(dicPath)/string", contents: "string")
                QPath.createFile(filePath: "\(dicPath)/img", contents: R.image.tabBar.home_h()!)
                if let img = R.image.tabBar.home_h(), let imgdata = img.pngData() {
                    QPath.createFile(filePath: "\(dicPath)/data", contents: imgdata)
                }
                
                /**
                 ➜  Documents tree
                 .
                 ├── 111.txt
                 ├── 222.txt
                 └── Img
                 ├── data
                 ├── img
                 └── string
                 
                 1 directory, 5 files
                 */
            }
        }
    }
}

class StringLenghtTest: QuickSpec {
    override func spec() {
        fdescribe("StringLenghtTest") {
            it("should print correct test data") {
                let num = "12345"
                let alp = "hah"
                let zh = "哈哈哈"
                print("数字:\(num.count)")
                print("字母:\(alp.count)")
                print("中文:\(zh.count)")
                print("数字#:\(num.fullwidthToHalfwidth().count)")
                print("字母#:\(alp.fullwidthToHalfwidth().count)")

                        var str = "ABCDEFG"
                //        let tmp = str[2, 5]
                //        print("tmp:\(tmp)")
                //        let tmp2 = str[2, 7]
                //        print("tmp2:\(tmp2)")
                //
                //        str[2, 4] = "cdef"
                //        print("str:\(str)")
                //        str[2, 7] = "cdefghijk"
                //        print("str:\(str)")
                
                let tmp = str[0]
                print("tmp:\(tmp)")
                // Prints tmp:A
                
                let tmp2 = str[5]
                print("tmp2:\(tmp2)")
                // Prints tmp2:F
                
                str[5] = "*"
                print("str:\(str)")
                // Prints str:ABCDE*G
                
                str[1] = "###"
                print("str:\(str)")
                // Prints str:A###CDE*G
                
                //str.containEmoji
                //subString
                let test = "abcdefg"
                let key = "cd"
                let r = test.nsRange(of: key)
                print("r: \(r)")
                
                let r2 = NSRange(location: 0, length: 3)
                let s = test.subString(with: r2)
                print("s: \(s)")

            }
        }
    }
}

//FIXME: 仍有很大误差
class ImageHandleTest: QuickSpec {
    override func spec() {
        fdescribe("ImageHandleTest") {
            it("should print correct test data") {
                let originImg = R.image.swift()
                print(originImg)
                let icon = originImg?.resize(maxpt: 30)
                print(icon)
                
                //let img = originImg?.compress(maxSize: <#T##Int#>)
                guard let data1 = originImg?.jpegData(compressionQuality: 0.9) else { return }
                guard let data2 = originImg?.pngData() else { return }

                let type = data2.imageType()
                
//                let ex = UIImage(named: "IMG_0197")?.imageExtensionName()
//                print(ex)
               
                let formatted = ByteCountFormatter.string(fromByteCount: Int64(data1.count), countStyle: .memory)
                print(formatted)

//                let img = UIImage.init(contentsOfFile: Bundle.main.path(forResource: "swift@2x", ofType: "png")!)
//                guard let data1 = img?.jpegData(compressionQuality: 0.9) else { return }
//                let formatted1 = ByteCountFormatter.string(fromByteCount: Int64(data1.count), countStyle: .file)
//                print(formatted1)

                if let icon2 = originImg?.compress(maxBytes: 3), let img = UIImage.init(data: icon2) {
                    print(img)
                }

            }
        }
    }
}

class AuthStatusTest: QuickSpec {
    override func spec() {
        fdescribe("test name") {
            it("should print correct test data") {
                AuthStatus.locationServices { (status) in
                    print("定位权限\(status ? "on": "off")")
                }
                AuthStatus.apnsServices { (status) in
                    print("推送权限\(status ? "on": "off")")
                }
                AuthStatus.cameraService { (status) in
                    print("相机权限\(status ? "on": "off")")
                }
                AuthStatus.albumService { (status) in
                    print("相册权限\(status ? "on": "off")")
                }
                AuthStatus.microphoneService { (status) in
                    print("麦克风权限\(status ? "on": "off")")
                }
                AuthStatus.bleService { (status) in
                    print("蓝牙权限\(status ? "on": "off")")
                }
                AuthStatus.cellularDataService { (status) in
                    print("蜂窝权限\(status ? "on": "off")")
                }
                AuthStatus.networkService { (status) in
                    print("网络状态\(status ? "on": "off")")
                }
            }
        }
    }
}

class StructTest: QuickSpec {
    override func spec() {
        fdescribe("StructTest") {
            it("should print correct test data") {
                
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

class ThemeModeTest: QuickSpec {
    override func spec() {
        fdescribe("ThemeModeTest") {
            it("should print correct test data") {
                
                let color1 = UIColor.init(hexStr: "#57CBFF")
                let color2 = UIColor.init(hexStr: "0x57CBFF")
                let color3 = UIColor.init(hexStr: "0X57CBFF")

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

            }
        }
    }
}

class DictionaryTest: QuickSpec {
    override func spec() {
        fdescribe("DictionaryTest") {
            it("should print correct test data") {
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

class StringTest: QuickSpec {
    override func spec() {
        fdescribe("StringTest") {
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
                //expect(10.0).to(beGreaterThan(10))
                //
            }
        }
    }
}
