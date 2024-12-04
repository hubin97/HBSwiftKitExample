//
//  BGTaskHandler.swift
//  Momcozy
//
//  Created by hubin.h on 2024/7/18.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import BackgroundTasks

class BGTaskManager {
    static let shared = BGTaskManager()
    // 是否启用此后台任务
    var isEnable = false
    
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var taskHandler: (() -> Void)?

    private init() {
        setupAppAvailableListen()
    }

    // MARK: - Public Methods

    /// 设置后台任务和业务处理逻辑
    ///
    /// - Parameter handler: 业务处理逻辑闭包
    func setupBackgroundTask(handler: (() -> Void)? = nil) {
        self.taskHandler = handler
        registerBackgroundTasks()
        scheduleBackgroundTask()
    }

    /// 开始后台任务
    private func startBackgroundTask() {
        if backgroundTask == .invalid {
            LogM.debug("开始后台任务")
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "BackgroundTask") {
                // 清理资源
                self.endBackgroundTask()
            }
        }
    }

    /// 结束后台任务
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            LogM.debug("结束后台任务")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

// MARK: - private mothods
extension BGTaskManager {

    private func setupAppAvailableListen() {
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) {[weak self] _ in
            if self?.isEnable == true {
                self?.endBackgroundTask()
            }
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) {[weak self] _ in
            if self?.isEnable == true {
                self?.startBackgroundTask()
            }
        }
    }
    
    /// 注册后台任务
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.app.keepAlive", using: nil) {[weak self] task in
            if let ttask = task as? BGProcessingTask {
                self?.handleBackgroundTask(task: ttask)
            }
        }
    }

    /// 调度后台任务
    private func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: "com.example.app.keepAlive")
        // 不需要网络连接
        request.requiresNetworkConnectivity = true
        // 不需要外部电源
        request.requiresExternalPower = false

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            LogM.debug("启用后台任务失败: \(error.localizedDescription)")
        }
    }

    /// 处理后台任务
    ///
    /// - Parameter task: 后台任务对象
    private func handleBackgroundTask(task: BGProcessingTask) {
        scheduleBackgroundTask() // 调度下次任务

        // 确保后台任务能够继续运行
        startBackgroundTask()

        task.expirationHandler = {
            // 清理资源
            self.endBackgroundTask()
        }

        // 执行传入的业务处理逻辑
        taskHandler?()

        task.setTaskCompleted(success: true)
    }
}
