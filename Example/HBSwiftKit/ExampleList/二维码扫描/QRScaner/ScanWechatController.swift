//
//  ScanWechatController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/2/2.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import AVFoundation
import opencv2

// MARK: - global var and methods
//iOS 编译opencv+wechat_qrcode, 生成opencv2.framework及使用 https://juejin.cn/post/7215496238627176504

// MARK: - main class
class ScanWechatController: BaseViewController {
    
    lazy var wechatQRCode: WeChatQRCode = {
        let path = Bundle.main.path(forResource: "wechat_qrcode", ofType: "bundle") ?? ""
        let detector_prototxt_path = path + "/detect.prototxt"
        let detector_caffe_model_path = path + "/detect.caffemodel"
        let super_resolution_prototxt_path = path + "/sr.prototxt"
        let super_resolution_caffe_model_path = path + "/sr.caffemodel"
        let _wechatQRCode = WeChatQRCode(detector_prototxt_path: detector_prototxt_path, detector_caffe_model_path: detector_caffe_model_path, super_resolution_prototxt_path: super_resolution_prototxt_path, super_resolution_caffe_model_path: super_resolution_caffe_model_path)
        return _wechatQRCode
    }()
    lazy var scaner: ScanCMSampleBuffer = {
        let _scaner = ScanCMSampleBuffer.init()
        _scaner.delegate = self
        return _scaner
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let _layer = scaner.previewLayer
        _layer.frame = scanerMaskView.bounds
        return _layer
    }()
    
    lazy var scanerMaskView: QRScanerView = {
        let _scanerMaskView = QRScanerView.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH - kNavBarAndSafeHeight - kBottomSafeHeight))
        return _scanerMaskView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "扫一扫"

        view.addSubview(scanerMaskView)
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        startScaner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScaner()
    }
    
    func startScaner() {
        DispatchQueue.global().async {
            self.scaner.session.startRunning()
            DispatchQueue.main.async {
                self.scanerMaskView.startScanAnimate()
            }
        }
    }
    
    func stopScaner() {
        DispatchQueue.global().async {
            self.scaner.session.stopRunning()
            DispatchQueue.main.async {
                self.scanerMaskView.stopScanAnimate()
            }
        }
    }
}

// MARK: - private mothods
extension ScanWechatController { 
}

// MARK: - call backs
extension ScanWechatController {
    
    func picTest() {
        if let path = Bundle.main.path(forResource: "qrcodetest.png", ofType: nil), let image = UIImage(contentsOfFile: path) {
            let mat = OpenCVWrapper.image(toMat: image)
            let result = wechatQRCode.detectAndDecode(img: mat)
            print("result>> \(result)")
        }
    }
}

// MARK: - delegate or data source
extension ScanWechatController: ScanCMSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = sampleBuffer.imageBuffer, let image = UIImage(ciImage: CIImage(cvImageBuffer: imageBuffer)).resize(maxpt: 500) else { return }
        // <UIImage:0x2838bda70 anonymous {1920, 1080} renderingMode=automatic(original)>
        // <UIImage:0x28026b3c0 anonymous {400, 400} renderingMode=automatic(original)>
        // FIXME: 注意:  image 的尺寸太大 detectAndDecode调用内部断言报错 闪退
        let mat = OpenCVWrapper.image(toMat: image)
        let result = wechatQRCode.detectAndDecode(img: mat)
        let array = NSMutableArray()
//        let result = wechatQRCode.detectAndDecode(img: mat, points: array)
        print("result>> \(result) array: \(array)")
        if result.count > 0 {
            
        }
    }
}
