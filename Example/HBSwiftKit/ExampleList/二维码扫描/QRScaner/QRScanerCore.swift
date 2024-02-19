//
//  QRScanerCore.swift
//  Momcozy
//
//  Created by hubin.h on 2023/1/23.
//  Copyright © 2020 路特创新. All rights reserved.

import UIKit
import AVFoundation

class QRScanerCore: NSObject {
    
    var session: AVCaptureSession?
    var videoInput: AVCaptureDeviceInput?
    var metadataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
    }
    weak var controller: UIViewController!
    
    convenience init(controller: UIViewController) {
        self.init()
        self.controller = controller
        
    }
    
    func setupCaptureSession() {
        self.session = AVCaptureSession()
        
        self.session?.sessionPreset = AVCaptureSession.Preset.high
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        do {
            try device.lockForConfiguration()
            guard device.hasFlash == true else {
                print("设备不支持Flash")
                return
            }
            //设置闪光灯为自动
            device.flashMode = AVCaptureDevice.FlashMode.auto
            device.unlockForConfiguration()
            
        } catch {
            
        }
        
        do {
            try self.videoInput = AVCaptureDeviceInput(device: device)
        } catch {
            
        }
        
        if let videoInput = self.videoInput {
            if self.session?.canAddInput(videoInput) == true {
                self.session?.addInput(videoInput)
            }
        }
        
        if self.session?.canAddOutput(self.metadataOutput) == true {
            self.session?.addOutput(self.metadataOutput)
            
            var availableTypes = [AVMetadataObject.ObjectType]()
            if self.metadataOutput.availableMetadataObjectTypes.contains(.qr) {
                availableTypes.append(.qr)
            }
            if self.metadataOutput.availableMetadataObjectTypes.contains(.ean13) {
                availableTypes.append(.ean13)
            }
            if self.metadataOutput.availableMetadataObjectTypes.contains(.ean8) {
                availableTypes.append(.ean8)
            }
            if self.metadataOutput.availableMetadataObjectTypes.contains(.code128) {
                availableTypes.append(.code128)
            }
            if self.metadataOutput.availableMetadataObjectTypes.contains(.code39) {
                availableTypes.append(.code39)
            }
            if self.metadataOutput.availableMetadataObjectTypes.contains(.code93) {
                availableTypes.append(.code93)
            }
            
            self.metadataOutput.metadataObjectTypes = availableTypes
        }
        
        if self.controller != nil {
            self.metadataOutput.setMetadataObjectsDelegate(self.controller as? AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
        }
        
        if let session = self.session {
            self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
            self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.previewLayer?.frame = self.controller.view.bounds
        }
        
        if let layer = self.previewLayer {
            self.controller.view.layer.insertSublayer(layer, at: 0)
        }
    }
}
