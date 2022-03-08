//
//  UIKitTestController.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/2/26.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import UIKit
import QuartzCore
// import opencv2

// MARK: - global var and methods

// MARK: - main class
class UIKitTestController: BaseViewController {

    lazy var filterModels: [AdvancedFilterSecModel] = {
        let path = Bundle.main.path(forResource: "advfilterdata", ofType: "json")
        let url = URL(fileURLWithPath: path ?? "")

        do {
            let json = try JSONSerialization.jsonObject(with: Data.init(contentsOf: url), options: .mutableContainers)
            if let dic = json as? [String: Any], let datas = dic["data"] as? [[String: Any]] {
                var models = [AdvancedFilterSecModel]()
                for dict in datas {
                    let secModel = AdvancedFilterSecModel.init()
                    secModel.sectitle = dict.keys.first ?? ""
                    secModel.isExpanded = false
                    if let rowDatas = dict.values.first as? [String] {
                        for rowdata in rowDatas {
                            let rowModel = AdvancedFilterRowModel.init()
                            rowModel.rowtitle = rowdata
                            rowModel.isSelected = false
                            secModel.rowModels.append(rowModel)
                        }
                    }
                    models.append(secModel)
                }
                return models
            }
        } catch {
            print("tojsonErro: \(error)")
        }
        return []
    }()

    lazy var tagsView: YTTagsView = {
        let tags = ["标签", "标签", "标签", "标签", "标签签", "标签", "标签", "标签", "标签标签", "标签标签标签签", "标签标签标签标签标签标签标签", "标签"]
        var ops = [TagsMeta]()
        for idx in 0..<tags.count {
            let title = tags[idx]
            let isSel = idx == 2 ? true: false
            ops.append(TagsMeta(title: title, param: ["\(idx)": title], isSelected: isSel))
        }
        // swiftlint:disable line_length
        let _tagsView = YTTagsView(title: "标题", isMultiple: true, options: ops, optionNormalBgColor: UIColor(hexStr: "#F1F1F3"), optionSelectBgColor: UIColor(hexStr: "#6165C5"), optionNormalTextColor: UIColor(hexStr: "#5E5E83"), optionSelectTextColor: .white, optionFont: UIFont.systemFont(ofSize: 15), optionMaxHeight: 40, actionTitle: "我知道了", actionTitleColor: .orange, tapAction: {[weak self] (tags) in
            self?.opPrint(ops: tags)
        })
        _tagsView.contentView.backgroundColor = .white
        _tagsView.titleLabel.textAlignment = .left
        return _tagsView
    }()

    var avPlayer: AVAudioPlayer?

    var allBrightList: [Int] {
        var temp = [Int]()
        for index in 0...100 {
            temp.append(index)
        }
        return temp
    }

    var signalPlate: SignalPlateView!
    var signalMark: SignalMarkView!
    override func setupUi() {
        super.setupUi()
        self.navigationItem.title = "UIKit Test"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "筛选", style: .plain, target: self, action: #selector(filterAction(_:)))

        //customBtn()
        //signalCheck()
        //attributedTest()
        starRateView()
    }
}

// MARK: - call backs
extension UIKitTestController {

    @objc func filterAction(_ sender: UIBarButtonItem) {
        // showRulerView()
        // showTagsView(nil)
        let picker = LightAttrPickerView(hsvColor: HsvColor(hue: 0, saturation: 0), duration: 3)
        //let picker = DPAttrsPickerView(mode: .brightness, duration: 3)
        //picker.pickerDatas = allBrightList
        picker.show()
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        let jsons = ###"[{"funcionName":"开启","functionCode":"group_function_on","ifBasic":1},{"funcionName":"开关分离设置","functionCode":"group_function_separate_key_and_relay","ifBasic":0},{"funcionName":"上电设置","functionCode":"group_function_power_on_relay_setting","ifBasic":0},{"funcionName":"关联智能常开","functionCode":"group_function_normally_open","ifBasic":0},{"funcionName":"关闭","functionCode":"group_function_off","ifBasic":1}]"###
//        print("jsons: \(jsons.data?.array)")
//
//
//        //DDLogWarn("warn hahah")
////        if self.signalPlate.isAnimating {
////            self.signalPlate.resultAngle(CGFloat.pi * CGFloat(arc4random()%26)/18)
////            self.signalMark.resultMark(Int(arc4random()%4))
////        } else {
////            signalMark.startAnimate(7)
////            signalPlate.startAnimate(7) {[weak self] in
////                self?.signalPlate.resultAngle(CGFloat.pi * 26/18)
////                self?.signalMark.resultMark(0)
////            }
////        }
//    }
}

// MARK: - Copyable
protocol Copyable {
    func copy() -> Self
}
class MyClass: Copyable {
    var num = 1
    func copy() -> Self {
        let type = type(of: self)
        let result = type.init()
        result.num = num
        return result
    }
    required init() {}
}

// MARK: - 测试代码
extension UIKitTestController {

    func starRateView() {
        let max = 6
        let rect = CGRect(x: 20, y: 40, width: kScreenW - 40, height: (kScreenW - 40)/CGFloat(max))
        let starView = StarRateView.init(frame: rect, starMax: max, rateValue: 0)
        starView.canAjust = true
        self.view.addSubview(starView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            starView.updateStarView(by: 0.6)
        }
    }

    /// 富文本测试
    func attributedTest() {
        let text = "1.打开查找功能\n2.输入你要替换的内容 比如,我这边想全局修改作者名称\n3.点击Find,会出现一个框,会有replace出来,就和我们文件内查找替换一样\n4.改成你想要的内容,点击replace all"
        let subText1 = "1.打开查找功能"
        let subText2 = "2.输入你要替换的内容 比如,我这边想全局修改作者名称"
        let subText3 = "3.点击Find,会出现一个框,会有replace出来,就和我们文件内查找替换一样"
        let subText4 = "点击Find"
        let subText5 = "会有replace出来"
        let textView = UITextView.init(frame: CGRect(x: 20, y: 20, width: kScreenW - 40, height: 200))
        view.addSubview(textView)
        textView.setRoundCorners(borderColor: UIColor.random, borderWidth: 1, isDotted: true, lineDashPattern: [5, 2])
        //textLabel.numberOfLines = 0
        textView.delegate = self
        textView.isEditable = false
        let attrs = NSMutableAttributedString(string: text).addAttr_font(UIFont.systemFont(ofSize: 15)).addAttr_fColor(.black).addAttr_kern(5)//.addAttr_lineSpacing(10, font: UIFont.systemFont(ofSize: 15))
//        attrs.addAttr_stroke(width: 4, color: .magenta, range: text.nsRange(of: subText1))
//            .addAttr_midline(lineWidth: 3, color: .random, range: text.nsRange(of: subText2))
//            .addAttr_underline(style: .single, color: .yellow, range: text.nsRange(of: subText3))
//            .addAttr_shadow(color: .random)
        // "https://github.com/hubin97/HBSwiftKitExample"
        attrs.addAttr_link(url: URL(string: "https://github.com/hubin97/HBSwiftKitExample")!, range: text.nsRange(of: subText4))
        //attrs.addAttr_textEffect(textEffect: .letterpressStyle, range: text.nsRange(of: subText5))
        textView.attributedText = attrs
    }

    /// 信号检测盘
    func signalCheck() {
        let size: CGFloat = kScaleW(300)
        signalPlate = SignalPlateView.init(frame: CGRect(x: (kScreenW - size)/2, y: 35, width: size, height: size))
        self.view.addSubview(signalPlate)
        signalPlate.startAnimate(14) {[weak self] in
            self?.signalPlate.resultAngle(CGFloat.pi * 13/36)
            self?.signalMark.resultMark(3)
        }

        signalMark = SignalMarkView.init(frame: CGRect(x: 0, y: signalPlate.maxY + 20, width: 0, height: 0))
        self.view.addSubview(signalMark)
        signalMark.centerX = signalPlate.centerX
        signalMark.startAnimate(14)
    }

    /// 自定义扩展按钮
    func customBtn() {
        let btn1 = UIButton.init(frame: CGRect(x: 20, y: 100, width: 300, height: 100))
        btn1.addTarget(self, action: #selector(btnAction1), for: .touchUpInside)
        btn1.setTitle("哈HH阿卡", for: .normal)
        btn1.setTitleColor(.black, for: .normal)
        btn1.titleLabel?.font = UIFont.systemFont(ofSize: kScaleW(30), weight: .semibold)
        btn1.drawTextLineColor = .orange
        btn1.drawTextLineWidth = 2
        btn1.showScaleAnimate = true
        view.addSubview(btn1)
        btn1.setRoundCorners(borderColor: .red)
    }

    @objc func btnAction1(_ sender: UIButton) {
        // print("btnAction1")
        print("\([Date()]) enter()")
        Throttler.shared.fire(duration: TimeInterval(3)) {
            print("\([Date()]) call()")
        }

//        print("\([Date()]) enter()")
//        let tt = Throttler.init(time: .milliseconds(500), queue: DispatchQueue.main, immediateFire: true) {
//            print("\([Date()]) call()")
//        }
//        tt.call()
    }

    /// 双列表关联
    func showDualList() {
        FamilyAreaOptionsView.init(data: nil).show()
    }

    /// 高级筛选器
    func filterView() {
        let filterView = AdvancedFilter.init()
        filterView.filterModels = self.filterModels
        filterView.show()
    }

    /// 弹性帧动画
    func bouncesAni() {
        let ball = UIImageView()
        let orignPoint = ball.center
        let animateKeyframes = CAKeyframeAnimation(keyPath: "position")
        animateKeyframes.duration = 2
        animateKeyframes.values = [NSValue(cgPoint: orignPoint),
                                   NSValue(cgPoint: CGPoint(x: orignPoint.x, y: orignPoint.y - 60)),
                                   NSValue(cgPoint: orignPoint),
                                   NSValue(cgPoint: CGPoint(x: orignPoint.x, y: orignPoint.y - 40)),
                                   NSValue(cgPoint: orignPoint),
                                   NSValue(cgPoint: CGPoint(x: orignPoint.x, y: orignPoint.y - 20)),
                                   NSValue(cgPoint: orignPoint),
                                   NSValue(cgPoint: CGPoint(x: orignPoint.x, y: orignPoint.y - 10)),
                                   NSValue(cgPoint: orignPoint)]
        animateKeyframes.keyTimes = [0, 0.2, 0.38, 0.52, 0.66, 0.76, 0.86, 0.93, 1]
        animateKeyframes.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
        ball.layer.add(animateKeyframes, forKey: nil)
    }

    /// 音频文件播放
    // 播放方式1
    func playSoundEffect(name: String, inCompletionBlock: (() -> Void)?) {
        guard let audioFile = Bundle.main.path(forResource: name, ofType: nil) else { return }
        let fileUrl = NSURL.fileURL(withPath: audioFile)

        var soundId: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundId)
        AudioServicesPlaySystemSoundWithCompletion(soundId, inCompletionBlock)
    }
    // 播放方式2
    func audioPlay(name: String) {
        guard let audioFile = Bundle.main.path(forResource: name, ofType: nil) else { return }
        let fileUrl = URL.init(fileURLWithPath: audioFile)
        guard let fileData = try? Data.init(contentsOf: fileUrl) else { return }
        do {
            let player = try AVAudioPlayer.init(data: fileData)
            player.delegate = self
            player.prepareToPlay()
            self.avPlayer = player
            print("准备播放")
        } catch {
            print("播放失败")
        }
    }

    /// 标签 瀑布流
    func showTagsView(_ sender: UIView?) {
        if let view = sender {
            let ff = view.convert(view.bounds, to: UIApplication.shared.keyWindow)
            tagsView.show(originFrame: ff)
        } else {
            tagsView.show()
        }
    }
    func opPrint(ops: [TagsMeta]?) {
        ops?.forEach({ (meta) in
            print("op_title:\(meta.title ?? "")")
            print("op_param:\(meta.param ?? 0)")
        })
    }

    /// 简易标尺
    func showRulerView() {
        let rulerView = SliderRuler.init(frame: CGRect(x: 20, y: 50, width: 50, height: 200), direction: .vertical, rulerLineSpacing: 7)
        view.addSubview(rulerView)
        // rulerView.setRulerValue(rulerValue: rulerValue, animated: true)
        rulerView.setRoundCorners()
    }
}

// MARK: - private mothods
import AudioToolbox
import AVFoundation
extension UIKitTestController: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying, flag:\(flag)")
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur, error: \(error?.localizedDescription ?? "")")
    }
}

public typealias AKAlertView = YTAlertView
extension AKAlertView {

    /** 默认间距变更
     // 标题与alert边框大间距
     fileprivate var kpadding = W_Scale(30)
     /// 标题与内容小间距
     fileprivate var s_kpadding = W_Scale(20)
     /// 左边距
     fileprivate var l_kpadding = W_Scale(15)
     */
    public convenience init(Aukey_title title: String?, message: String?, alertWidth: CGFloat = 250, kpadding: CGFloat = 30, s_kpadding: CGFloat = 20, l_kpadding: CGFloat = 15) {
        self.init(frame: CGRect.zero)
        self.alert_width = alertWidth
        self.kpadding = kpadding
        self.s_kpadding = s_kpadding
        self.l_kpadding = l_kpadding
        setup(title: title, message: message, actions: nil)
    }

    public convenience init(Aukey_title title: String?, icon: String?, iconSize: CGSize? = nil, message: String?, alertWidth: CGFloat = 250, kpadding: CGFloat = 30, s_kpadding: CGFloat = 20, l_kpadding: CGFloat = 15) {
        self.init(frame: CGRect.zero)
        self.alert_width = alertWidth
        self.kpadding = kpadding
        self.s_kpadding = s_kpadding
        self.l_kpadding = l_kpadding
        setup(title: title, icon: icon, iconSize: iconSize, message: message, actions: nil)
    }
}

extension UIKitTestController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
        return true
    }
}

// 单元测试
class SwiftFuncInvokeTest {

    required init() {
    }

    func test1() {
        print("test1")
    }

    func test2(param: String) {
        print("test2: \(param)")
    }
}

// 节流
class Throttler {
    static let shared = Throttler()
    var isValid = true
    func fire(duration: TimeInterval, completeHandle: (() -> Void)?) {
        guard isValid else { return }
        self.isValid = false
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.isValid = true
            completeHandle?()
        }
    }
}
