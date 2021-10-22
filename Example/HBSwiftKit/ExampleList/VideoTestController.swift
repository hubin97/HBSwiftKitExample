//
//  VideoTestController.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/10/8.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import AVKit
import MobileCoreServices

// MARK: - global var and methods

// MARK: - main class
class VideoTestController: BaseViewController {

    lazy var rightEditBtn: UIButton = {
        let rightEditBtn = UIButton.init(type: .custom)
        rightEditBtn.setTitle("选择", for: .normal)
        rightEditBtn.setTitleColor(.black, for: .normal)
        rightEditBtn.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        return rightEditBtn
    }()

    override func setupUi() {
        super.setupUi()
        self.navigationItem.title = "视频剪辑测试"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.rightEditBtn)
    }
}

// MARK: - private mothods
extension VideoTestController {

}

// MARK: - call backs
extension VideoTestController {

    @objc func editAction() {
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = self
        pickerVC.modalPresentationStyle = .currentContext
        // pickerVC.videoQuality = .typeMedium
        pickerVC.mediaTypes = [kUTTypeMovie as String]
        pickerVC.allowsEditing = true
        // pickerVC.videoMaximumDuration = 10  /// 限制裁剪长度
        self.navigationController?.present(pickerVC, animated: true, completion: nil)
    }
}

// MARK: - delegate or data source
extension VideoTestController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        print("didFinishPickingMediaWithInfo1---")
        self.navigationController?.dismiss(animated: true, completion: { [weak self] in
            if let url = info[UIImagePickerControllerMediaURL] as? URL {
                let asset = AVAsset.init(url: url)
                print("asset---\(CMTimeGetSeconds(asset.duration))")
                // self?.cropHandle(asset: asset, whRatio: 3.0/4)
                // self?.timeView.configData(avAsset: asset)
                let vc = VideoCropController()
                vc.cropConfig(asset: asset)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
}

// MARK: - other classes
