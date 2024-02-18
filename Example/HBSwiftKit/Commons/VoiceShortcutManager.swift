//
//  VoiceShortcutManager.swift
//  WingToSmart
//
//  Created by Hubin_Huang on 2022/7/7.
//  Copyright © 2020 Hubin_Huang. All rights reserved.

//import Foundation
import IntentsUI

// MARK: - main class
class VoiceShortcutManager: NSObject {
    typealias T = INIntent

    // 操作方式
    enum IntentAction {
        case add, edit, delete, cancel
    }

    static let shared = VoiceShortcutManager()
    // 指令更新回调
    var shortcutsUpdateBlock: ((_ iAction: IntentAction, _ voiceShortcut: INVoiceShortcut?) -> Void)?
    // 匹配的全量指令
    var allShortcuts: [INVoiceShortcut] = []
}

// MARK: - private mothods
extension VoiceShortcutManager {

    // MARK: 自定义Intents
    /// 获取所有匹配意图的快捷指令
    /// - Parameters:
    ///   - targetIntent: 指定匹配意图
    ///   - completeHandle: 异步回调快捷指令数组
    func getAllVoiceShortcuts<T>(targetIntent: T.Type, completeHandle: @escaping (_ shortcuts: [INVoiceShortcut]?, _ error: Error?) -> Void) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts {[weak self] voiceShortcuts, error in
            guard let self = self, error == nil else {
                completeHandle(nil, error)
                return
            }
            self.allShortcuts.removeAll()
            DispatchQueue.main.async {
                if let voiceShortcuts = voiceShortcuts {
                    for shortcut in voiceShortcuts where shortcut.shortcut.intent is T {
                        self.allShortcuts.append(shortcut)
                    }
                }
                completeHandle(self.allShortcuts, nil)
            }
        }
    }

    /// 添加指令
    /// - Parameter shortcut: 构建的快捷指令数据
    func addShortcut(_ shortcut: INShortcut) {
        let addShortcutVc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        addShortcutVc.delegate = self
        addShortcutVc.modalPresentationStyle = .fullScreen
        stackTopViewController()?.present(addShortcutVc, animated: true)
    }

    /// 编辑指令
    /// - Parameter vShortcut: 选中的快捷指令
    func editShortcut(_ vShortcut: INVoiceShortcut) {
        let editShortcutVc = INUIEditVoiceShortcutViewController.init(voiceShortcut: vShortcut)
        editShortcutVc.delegate = self
        editShortcutVc.modalPresentationStyle = .fullScreen
        stackTopViewController()?.present(editShortcutVc, animated: true)
    }

    // MARK: 捐赠方式调用
    /**
     // 添加
     let intent = WingtoDonateIntent()
     intent.title = "第\(idx)个捐赠快捷指令"
     intent.sid = "25709"
     intent.suggestedInvocationPhrase = "捐赠指令\(idx)"
     let interaction = INInteraction(intent: intent, response: nil)
     interaction.donate { error in
         print("donate intent error:", error as Any)
     }
     // 删除
     INInteraction.deleteAll()
     */
    func addDonateShortcut(intent: INIntent, completion: ((_ error: Error?) -> Void )? = nil) {
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate(completion: completion)
    }
}

// MARK: INUIAddVoiceShortcutViewControllerDelegate
extension VoiceShortcutManager: INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {

    // MARK: INUIAddVoiceShortcutViewControllerDelegate
    /// 增加
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let tVoiceShortcut = voiceShortcut, let phrase = voiceShortcut?.invocationPhrase {
            print("Add=>voiceShortcut:\(phrase)")
            allShortcuts.append(tVoiceShortcut)
        }
        controller.dismiss(animated: true) {
            self.shortcutsUpdateBlock?(.add, voiceShortcut)
        }
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true) {
            self.shortcutsUpdateBlock?(.cancel, nil)
        }
    }

    // MARK: INUIEditVoiceShortcutViewControllerDelegate
    /// 更新
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let tVoiceShortcut = voiceShortcut, let phrase = voiceShortcut?.invocationPhrase {
            print("Edit=>voiceShortcut:\(phrase)")
            for (offset, element) in allShortcuts.enumerated() where element.identifier == tVoiceShortcut.identifier {
                allShortcuts[offset] = tVoiceShortcut
                break
            }
        }
        controller.dismiss(animated: true) {
            self.shortcutsUpdateBlock?(.edit, voiceShortcut)
        }
    }

    /// 删除
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        print("Delete=>identifier:\(deletedVoiceShortcutIdentifier)")
        allShortcuts = allShortcuts.filter({ $0.identifier != deletedVoiceShortcutIdentifier })
        controller.dismiss(animated: true) {
            self.shortcutsUpdateBlock?(.delete, nil)
        }
    }

    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true) {
            self.shortcutsUpdateBlock?(.cancel, nil)
        }
    }
}
