//
//  DesignMode.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2022/4/8.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation

// MARK: - 单例模式
class Singleton {
    static let shared = Singleton()
    private init() {}
}

// MARK: - 责任链
class BusinessObject {
    // 下一个业务,
    var nextBusiness: BusinessObject?
    // handled: 处理完是否需要上抛数据, 并结束责任链
    typealias CompletionBlock = ((_ handled: Bool) -> Void)
    typealias HandleBlock = ((_ handler: BusinessObject?, _ handled: Bool) -> Void)

    func handle(resultBlock: @escaping HandleBlock) {
        let completionBlock: CompletionBlock = {[weak self] handled in
            guard let weakSelf = self else { return }
            if handled {
                resultBlock(weakSelf, handled)
            } else {
                if weakSelf.nextBusiness != nil {
                    weakSelf.nextBusiness?.handle(resultBlock: resultBlock)
                } else {
                    resultBlock(nil, false)
                }
            }
        }
        self.handleBusiness(block: completionBlock)
    }

    // 当前业务处理, 最后回调是否终止责任链
    func handleBusiness(block: CompletionBlock) {
        defer {
            block(false)
        }
        printLog(self)
    }
}

class BusObjA: BusinessObject {}
class BusObjB: BusinessObject {}
class BusObjC: BusinessObject {}

class BusHanler {
    func startHandle() {
        let obja = BusObjA()
        let objb = BusObjB()
        let objc = BusObjC()
//        obja.nextBusiness = objb
//        objb.nextBusiness = objc
        obja.nextBusiness = objc
        objc.nextBusiness = objb
        obja.handle { busOjb, handled in
            printLog("busOjb: \(busOjb), handled:\(handled)")
        }
    }
    /**
     DesignMode.swift[line:42,method:handleBusiness(block:)]: HBSwiftKit_Example.BusObjA
     DesignMode.swift[line:42,method:handleBusiness(block:)]: HBSwiftKit_Example.BusObjB
     DesignMode.swift[line:42,method:handleBusiness(block:)]: HBSwiftKit_Example.BusObjC
     DesignMode.swift[line:65,method:startHandle()]: busOjb: nil, handled:false

     DesignMode.swift[line:45,method:handleBusiness(block:)]: HBSwiftKit_Example.BusObjA
     DesignMode.swift[line:45,method:handleBusiness(block:)]: HBSwiftKit_Example.BusObjC
     DesignMode.swift[line:45,method:handleBusiness(block:)]: HBSwiftKit_Example.BusObjB
     DesignMode.swift[line:64,method:startHandle()]: busOjb: nil, handled:false
     */
}

// MARK: - 桥接
// 抽象类B
class AbstractObjB {
    func fetchData() {}
}
// 抽象类A
class AbstractObjA {
    var objB: AbstractObjB?
    func handleData() {
        objB?.fetchData()
    }
}

class AbsObjA1: AbstractObjA {}
class AbsObjA2: AbstractObjA {}
class AbsObjA3: AbstractObjA {
    override func handleData() {
        // todo 自己的业务逻辑
        super.handleData()
        // todo 自己的业务逻辑
    }
}

class AbsObjB1: AbstractObjB {}
class AbsObjB2: AbstractObjB {}
class AbsObjB3: AbstractObjB {}

// 演示
class BridgeDemo {
    func demo() {
        let a1: AbstractObjA = AbsObjA1()
        let b1: AbstractObjB = AbsObjB1()
        a1.objB = b1
        a1.handleData()
    }
}

// MARK: - 适配器
// 目标旧对象
class Target {
    func oldMethod() {}
}

// 适配器对象
class AdapterTarget {
    var target: Target?
    func newMethod() {
        // 额外处理逻辑
        target?.oldMethod()
        // 额外处理逻辑
    }
}

// MARK: - 命令
class Command: Equatable {
    // 假定每个命令有不同的标记
    var mark: Int = 0
    var completion: ((_ cmd: Command) -> Void)?
    func execute() {
        done()
    }
    func cancel() {
        completion = nil
    }
    func done() {
        DispatchQueue.main.async {[weak self] in
            guard let ws = self else { return }
            ws.completion?(ws)
            ws.cancel()
            CommandManager.shared.commands.removeAll(where: { $0 == self })
        }
    }
    // Equatable
    static func == (lhs: Command, rhs: Command) -> Bool {
        return lhs.mark == rhs.mark
    }
}

class CommandManager {
    static let shared = CommandManager()
    var commands = [Command]()
    private init() {}

    static func isExecuting(with cmd: Command) -> Bool {
        if CommandManager.shared.commands.first(where: { $0.mark == cmd.mark }) != nil {
            return true
        }
        return false
    }
    static func execute(cmd: Command, completion: @escaping ((_ cmd: Command) -> Void)) {
        guard !isExecuting(with: cmd) else { return }
        CommandManager.shared.commands.append(cmd)
        cmd.completion = completion
        cmd.execute()
    }
    static func cancel(cmd: Command) {
        CommandManager.shared.commands.removeAll(where: { $0 == cmd })
        cmd.cancel()
    }
}
