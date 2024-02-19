//
//  ScanCMSampleBuffer.swift
//  WingToSmart
//
//  Created by Hubin_Huang on 2021/10/13.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import AVKit

// MARK: -
protocol ScanCMSampleBufferDelegate: AnyObject {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
}

/// 视频图像捕获类
class ScanCMSampleBuffer: NSObject {

    /// 回调捕获的ScanCMSampleBuffer
    var callBackCMSampleBuffer: ((_ sampleBuffer: CMSampleBuffer) -> Void)?
    weak var delegate: ScanCMSampleBufferDelegate?

    /// 回调间隔
    var encoderInterval: Double = 1
    /// 是否处于回调间隔中
    var encodering = false

    lazy var session: AVCaptureSession = {
        let _session = AVCaptureSession.init()
        if _session.canSetSessionPreset(.high) {
            _session.sessionPreset = .high
        }
        return _session
    }()
    lazy var input: AVCaptureDeviceInput? = {
        guard let device = camera(with: .back) else { return nil }
        return try? AVCaptureDeviceInput.init(device: device)
    }()
    lazy var output: AVCaptureVideoDataOutput = {
        let _videoOutput = AVCaptureVideoDataOutput.init()
        return _videoOutput
    }()
    lazy var connection: AVCaptureConnection? = {
        let _connection = output.connection(with: .video)
        return _connection
    }()

    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let _previewLayer = AVCaptureVideoPreviewLayer(session: session)
        _previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return _previewLayer
    }()

    override init() {
        super.init()

        // 配置
        if let input = input { session.addInput(input) }
        session.addOutput(output)
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        //output.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA]
        connection?.isVideoMirrored = true

        // 防抖
        if connection?.isVideoStabilizationSupported == true {
            connection?.preferredVideoStabilizationMode = .auto
        }

        // 设置视频的方向 不设置时,系统默认偏转90度
        connection?.videoOrientation = .portrait
        if (UIDevice.current.orientation == .portrait) {
            connection?.videoOrientation = .landscapeRight
        }
    }

    deinit {
        session.stopRunning()
    }

    /// 获取前/后置摄像头
    func camera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        var deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera, .builtInTelephotoCamera]
        if #available(iOS 11.1, *) {
            deviceTypes.append(contentsOf: [.builtInDualCamera, .builtInTrueDepthCamera])
        }
        let disSession = AVCaptureDevice.DiscoverySession.init(deviceTypes: deviceTypes, mediaType: .video, position: position)
        return disSession.devices.first
    }
}

extension ScanCMSampleBuffer: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !self.encodering == true {
            self.callBackCMSampleBuffer?(sampleBuffer)
            self.delegate?.captureOutput(output, didOutput: sampleBuffer, from: connection)
            self.encodering = true
            DispatchQueue.main.asyncAfter(deadline: .now() + self.encoderInterval) {
                self.encodering = false
            }
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
}
