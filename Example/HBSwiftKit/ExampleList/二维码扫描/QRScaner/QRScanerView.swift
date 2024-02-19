//
//  QRScanerView.swift
//  Momcozy
//
//  Created by hubin.h on 2023/1/23.
//  Copyright © 2020 路特创新. All rights reserved.

import UIKit
import AVFoundation
//import LuteBase

// 以6s为准的缩放比例
private func kScaleW(_ x: CGFloat) -> CGFloat {
    return UIScreen.main.bounds.width / 375 * x
}

class QRScanerView: UIView {

    var callBackInput: (() -> Void)?
    private var borderWidth: CGFloat = kScaleW(290)
    private var isLightOn: Bool = true
    private let scanLineWidth: CGFloat = 20
    private var offsetY: CGFloat?

    lazy var borderView: UIImageView = {
        let x = self.bounds.size.width/2 - borderWidth/2
        let y = offsetY ?? self.bounds.size.height/2 - borderWidth/2
        let _borderView: UIImageView = UIImageView(image: R.image.icon_qrcode_frame())
        _borderView.frame = CGRect.init(x: x, y: y, width: borderWidth, height: borderWidth)
        _borderView.layer.masksToBounds = true
        return _borderView
    }()

    lazy var scanLineView: UIImageView = {
        let _scanLineView: UIImageView = UIImageView(image: R.image.icon_qrcode_line())
        _scanLineView.frame = CGRect(x: 10, y: -scanLineWidth + 20, width: borderWidth - 20, height: scanLineWidth)
        return _scanLineView
    }()

    lazy var tipLabel: UILabel = {
        let _tipLabel = UILabel(frame: CGRect(x: 25, y: borderView.frame.maxY + 10, width: bounds.width - 50, height: 40))
        _tipLabel.text = "Please scan the QR code on the breast pump body".localized
        _tipLabel.textColor = UIColor.white
        _tipLabel.font = UIFont.systemFont(ofSize: 14)
        _tipLabel.textAlignment = .center
        _tipLabel.numberOfLines = 0
        return _tipLabel
    }()

    lazy var torchBtn: UIButton = {
        let _torchBtn = UIButton(type: .custom)
        _torchBtn.frame = CGRect(x: (bounds.width - kScaleW(48))/2, y: tipLabel.maxY + 20, width: kScaleW(48), height: kScaleW(48))
        _torchBtn.setImage(R.image.icon_qrcode_torch(), for: .normal)
        _torchBtn.imageView?.contentMode = .scaleAspectFit
        //_torchBtn.titleLabel?.font = UIFont.systemFont(ofSize: kScaleW(13), weight: .medium)
        //_torchBtn.setTitleColor(.white, for: .normal)
        //_torchBtn.setTitle("Tap to light up".localized, for: .normal)
        //_torchBtn.titleLabel?.textAlignment = .center
        _torchBtn.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        return _torchBtn
    }()
    
//    lazy var imgExampleView: UIImageView = {
//        let _imgExampleView = UIImageView(image: R.image.icon_qrcode_eg())
//        _imgExampleView.contentMode = .scaleAspectFit
//        _imgExampleView.frame = CGRect(x: (bounds.width - kScaleW(190))/2, y: torchBtn.maxY + 15, width: kScaleW(190), height: kScaleW(126))
//        return _imgExampleView
//    }()
    
//    lazy var caseButton: LoginButton = {
//        let y: CGFloat = bounds.height - kBottomSafeHeight - 24 - 48
//        let _loginButton = LoginButton(type: .custom)
//        _loginButton.frame = CGRect(x: 25, y: y, width: bounds.width - 50, height: 48)
//        _loginButton.setTitle("Other binding methods".localized, for: .normal)
//        _loginButton.setTitleColor(Colors.thinBlack, for: .normal)
//        _loginButton.setBackgroundImage(UIImage(color: .white), for: .normal)
//        _loginButton.setBackgroundImage(UIImage(color: .lightGray), for: .highlighted)
//        _loginButton.addTarget(self, action: #selector(caseAction), for: .touchUpInside)
//        return _loginButton
//    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    /// 快捷
    /// - Parameters:
    ///   - frame: frame
    ///   - size: 大小
    ///   - offsetY: 偏移
    convenience init(frame: CGRect, size: CGFloat = kScaleW(290), offsetY: CGFloat? = nil) {
        self.init(frame: frame)
        self.borderWidth = size
        self.offsetY = offsetY
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
//        if let temp = self.getCoverView() {
//            let imageView = UIImageView.init(frame: self.bounds)
//            imageView.image = temp
//            self.addSubview(imageView)
//        }
        self.addSubview(borderView)
        borderView.addSubview(scanLineView)
        self.addSubview(tipLabel)
        self.addSubview(torchBtn)
//        self.addSubview(imgExampleView)
//        self.addSubview(caseButton)
    }
    
//    @objc func caseAction() {
//        viewController()?.navigationController?.pushViewController(ScanPumpController(), animated: true)
//    }
}

extension QRScanerView {

    // 扫描动画
    func startScanAnimate() {
        let orignPoint = scanLineView.center
        let targetPoint = CGPoint(x: orignPoint.x, y: orignPoint.y + borderWidth - scanLineWidth)
        let anni = CABasicAnimation.init(keyPath: "position")
        anni.fromValue = NSValue(cgPoint: orignPoint)
        anni.toValue = NSValue(cgPoint: targetPoint)
        anni.duration = 2
        anni.repeatCount = MAXFLOAT
        anni.timingFunction = CAMediaTimingFunction(name: .easeIn)
        self.scanLineView.layer.add(anni, forKey: nil)
    }

    func stopScanAnimate() {
        self.scanLineView.layer.removeAllAnimations()
    }

    func getCoverView() -> UIImage? {
        let left = self.bounds.size.width/2 - borderWidth/2
        let top = self.bounds.size.height/2 - borderWidth/2 + (offsetY ?? 0)
        UIGraphicsBeginImageContext(CGSize(width: self.bounds.size.width, height: self.bounds.size.height))
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.setFillColor(UIColor.init(white: 0, alpha: 0.5).cgColor)
        contextRef?.fill(CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        let inset: CGFloat =   0
        contextRef?.clear(CGRect(x: left + inset, y: top + inset, width: borderWidth, height: borderWidth))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    @objc func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        do {
            try device.lockForConfiguration()
            guard device.hasTorch == true else { return }
            if isLightOn {
                device.torchMode = AVCaptureDevice.TorchMode.on
                isLightOn = false
            } else {
                device.torchMode = AVCaptureDevice.TorchMode.off
                isLightOn = true
            }
            device.unlockForConfiguration()
        } catch {
            return
        }
    }

    @objc func tapInputAction() {
        callBackInput?()
    }
}

extension QRScanerView {
    
    // 80 * 80  48 * 80
    class TorchBtn: UIButton {
        
        override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
            var imageRect = contentRect
            imageRect.size.width = kScaleW(48)
            imageRect.origin.x = (contentRect.size.width - imageRect.size.width)/2
            imageRect.size.height = imageRect.size.width
            return imageRect
        }
        
        override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
            var titleRect = contentRect
            titleRect.origin.y = kScaleW(48)
            titleRect.size.height = contentRect.height - titleRect.origin.y
            return titleRect
        }
    }
}
