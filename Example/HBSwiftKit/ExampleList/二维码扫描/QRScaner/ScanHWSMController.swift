//
//  ScanHWSMController.swift
//  
//
//  Created by Hubin_Huang on 2021/6/25.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import ScanKitFrameWork
import LuteBase

// https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides-V5/faq-0000001050747017-V5

// MARK: - main class
class ScanHWSMController: LTViewController {
   
    // FIXME: 节流控制, 暂停后不再识别
    var encodering = false
    lazy var hmsCustomScanVc: HmsCustomScanViewController = {
        let options = HmsScanOptions(scanFormatType: UInt32(HMSScanFormatTypeCode.ALL.rawValue), photo: false)
        let _hmsCustomScanVc = HmsCustomScanViewController.init(customizedScanWithFormatType: options)
        _hmsCustomScanVc?.customizedScanDelegate = self
        // 返回按钮，若需要隐藏赋值为true
        _hmsCustomScanVc?.backButtonHidden = true
        // 赋值true为持续扫码，默认为false非持续扫码。
        _hmsCustomScanVc?.continuouslyScan = true
        return _hmsCustomScanVc!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(hmsCustomScanVc.view)
        addChild(hmsCustomScanVc)
        didMove(toParent: hmsCustomScanVc)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        AuthStatus.cameraService {[weak self] granted in
            guard let ws = self, let granted = granted, granted else {
                AuthStatus.openSettingsAlert(.camera)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ws.startScaner()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopScaner()
    }
    
    func startScaner() {
        self.encodering = false
        hmsCustomScanVc.resumeContinuouslyScan()
    }
    
    func stopScaner() {
        hmsCustomScanVc.pauseContinuouslyScan()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func qrcodeHandle(qrcode: String) {}
}

extension ScanHWSMController: CustomizedScanDelegate {
    
    func customizedScanDelegate(forResult resultDic: [AnyHashable : Any]!) {
        guard let value = resultDic?.data?.dict?.value(forKey: "text") as? String, value.isEmpty == false else { return }
        self.stopScaner()
        DispatchQueue.main.async {
            if !self.encodering {
                self.encodering = true
                self.qrcodeHandle(qrcode: value)
            }
        }
    }
}
