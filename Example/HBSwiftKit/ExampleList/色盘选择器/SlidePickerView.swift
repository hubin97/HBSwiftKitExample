//
//  SlidePickerView.swift

import UIKit
import StoreKit
import HBSwiftKit

protocol SlidePickerDelegate: AnyObject {
    func showFinish(type: SlidePickerView)
    func hiddenFinish(type: SlidePickerView)
}

class SlidePickerView: UIView {
    //高度
    var h: CGFloat {
        return kScaleW(370) + kBottomSafeHeight
    }
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    var startY: CGFloat = 0
    var isPanAvilable = false

    weak var slidePickerDelegate: SlidePickerDelegate?

    /// 灰色蒙层
    var grayView: UIView?
    var isMask: Bool = false
    var isMaskDisappear = true
    var topsView: UIView!
    convenience init() {
        self.init(frame: CGRect(x: 0, y: kScreenH, width: kScreenW, height: 0))
        height = h
        UIApplication.shared.keyWindow?.addSubview(self)
        backgroundColor = .white
        let path = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        layer.mask = maskLayer

        let topsView = UIView.init(frame: CGRect(x: width/2 - kScaleW(15), y: kScaleW(10), width: kScaleW(30), height: kScaleW(4)))
        topsView.backgroundColor = UIColor(hexStr: "0xD8D8D8")
        topsView.setRectCorner(radiiSize: 2)
        addSubview(topsView)
        self.topsView = topsView

        setUI()
    }

    convenience init(isMask: Bool, isMaskDisappear: Bool) {
        self.init()
        self.isMask = isMask
        self.isMaskDisappear = isMaskDisappear
        let grayView = UIView.init(frame: UIScreen.main.bounds)
        grayView.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        UIApplication.shared.keyWindow?.addSubview(grayView)
        UIApplication.shared.keyWindow?.bringSubviewToFront(self)
        grayView.isHidden = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(tap:)))
        grayView.isUserInteractionEnabled = true
        grayView.addGestureRecognizer(tap)
        self.grayView = grayView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {

    }
}

// MARK: -
extension SlidePickerView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            if ceil(Double(self.minY)) >= ceil(Double((kScreenH - self.h))) {
                self.isPanAvilable = true
                startY = point.y
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            if self.isPanAvilable && ceil(Double(self.minY)) >= ceil(Double((kScreenH - self.h))) {
                let newY = point.y
                let dy = newY - startY
                self.minY = max(self.minY + dy, CGFloat(ceil(Double((kScreenH - self.h)))))
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            if self.isPanAvilable {
                let newY = point.y
                let dy = newY - startY
                if dy > 0 {
                    self.hidden()
                } else {
                    if self.minY > (kScreenH - 2 * self.h/3) {
                        self.hidden()
                    } else {
                        self.show()
                    }
                }
                self.isPanAvilable = false
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            if self.isPanAvilable {
                let newY = point.y
                let dy = newY - startY
                if dy > 0 {
                    self.hidden()
                } else {
                    if self.minY > (kScreenH - 2 * self.h/3) {
                        self.hidden()
                    } else {
                        self.show()
                    }
                }
                self.isPanAvilable = false
            }
        }
    }
}

extension SlidePickerView {

    @objc func tapAction(tap: UITapGestureRecognizer) {
        if !self.isPanAvilable {
            grayView?.isHidden = true
            self.hidden()
        }
    }

    func show() {
        UIView.animate(withDuration: 0.3) {
            self.minY = kScreenH - self.h
        } completion: { (_) in
            self.grayView?.isHidden = false
            self.slidePickerDelegate?.showFinish(type: self)
        }
    }

    func hidden() {
        self.grayView?.isHidden = true
        let scale = (kScreenH - self.minY)/self.h
        UIView.animate(withDuration: 0.3 * Double(scale)) {
            self.minY = kScreenH
        } completion: { (_) in
            self.slidePickerDelegate?.hiddenFinish(type: self)
        }
    }
}
