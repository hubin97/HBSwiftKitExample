//
//  CtlThrottle.swift
//  WingToSmart
//
//  Created by Hubin_Huang on 2021/11/5.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation

public class CtlThrottler {
    public static let shared = CtlThrottler()
    public var schedule: TimeInterval = 0.5

    private var isValid = true
    public func fire(duration: TimeInterval? = nil, completionHandler: (() -> Void)?) {
        guard isValid else { return }
        self.isValid = false
        completionHandler?()
        DispatchQueue.main.asyncAfter(deadline: .now() + (duration ?? schedule)) { [weak self] in
            self?.isValid = true
        }
    }
}
