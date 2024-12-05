# BLE

### 功能
BLE模块主要提供以下功能：

```
// 1 链式实现
1. 蓝牙管理器 支持扫描开始结束; 连接状态,超时机制及通道就绪回调
2. 支持设置 自动重连, 重连次数, 重连超时
3. 支持自定义外设匹配策略
4. 支持设置目标服务UUID
5. 支持设置读,写及通知特征值UUID
6. 支持设置debug模式
7. 支持设置日志tag
8. 支持自定义外设广播包数据解析器
9. 支持多外设连接, 写入数据
10. 支持写入超时处理

// 2 Rx扩展
1. 消息序列化, 全局可订阅

// 3 问题点
1. 日志输出插入的时间不是实时的
```

### 使用说明

#### 1. 声明和配置

```swift
let bleManager: BLEManager = {
    return BLEManager.shared
        .setDebugMode(true) // 开启调试模式, 打印日志
        .setLogTag("[BLEManager]: ") // 插入日志标记
        .enableAutoReconnect(true)   // 开启自动重连 支持设置最大重连次数和重连超时
        .setMatchingStrategy(RegexMatchingStrategy(mode: .advertisementData([0xaa, 0x01]))) // 匹配策略
        .setAdvertisementParser(MACParser()) // 广播包解析器 (MAC地址解析器, 由外部业务而定)
        .setTargetServices([CBUUID(string: "AF00")])  // "AF00": 服务UUID
        .setWriteCharUUID(CBUUID(string: "AF01"))     // "AF01": 写特征UUID
        .setNotifyCharUUID(CBUUID(string: "AF02"))    // "AF02": 通知特征UUID
        .setOpenWriteTimeout(true) // 开启写入超时处理
        .setCmdComparisonRule { cmdData, ackData in   // 指令超时使用比较规则
            let reqData = cmdData.data
            let success = reqData[0] == ackData[0] && reqData[1] == ackData[1] && reqData[3] == ackData[3]
            print("比较: \(success ? "成功" : "失败"), \(success ? "" : "\(reqData[3]) != \(ackData[3])")")
            return success
        }
}()
```

#### 2. 扫描外设

```swift
// 开始扫描
bleManager.startScanning(timeout: 20)
// 停止扫描
bleManager.stopScanning()
```

#### 3. 连接外设

```swift
// 断开连接
bleManager.disconnect(p)
// 连接外设
bleManager.connect(to: [peripherals[indexPath.row]], timeout: 10)
```

#### 4. 链式回调

```swift
bleManager
    .setOnStateChanged { state in
        print("蓝牙状态更新: \(state.rawValue)")
    }
    .setOnPeripheralDiscoveredWithParser {[weak self] (peripheral, pDataProvider, parse: String?) in
        if let self = self, let data = parse, let manufacturerData = pDataProvider.advertisementData["kCBAdvDataManufacturerData"] as? Data {
            let manufacturerBytes = [UInt8](manufacturerData).map({String(format: "%02x", $0).uppercased()})
            print("发现外设: \(peripheral.name ?? "未知") 广播包: \(manufacturerBytes) 信号: \(pDataProvider.rssi) 解析Mac地址: \(data)")
            self.peripherals.append(peripheral)
            self.listView.reloadData()
        }
    }
    .setOnScanStateChange {[weak self] state in
        guard let self = self else { return }
        print("扫描状态更新: \(state)")
        switch state {
        case .started:
            break
        case .stopped:
            print("扫描完成. 共发现 \(peripherals.count) 个外设, 共: \(self.bleManager.discoveredPeripherals.map({ $0.name ?? "未知" }))")
        }
    }
    .setOnConnectionStateChange {[weak self] state, peripheral in
        guard let self = self else { return }
        self.updatePreipherals(with: peripheral)
        switch state {
        case .connecting(let peripheral):
            print("连接中: \(peripheral.name ?? "未知")")
        case .connected(let peripheral):
            print("连接成功: \(peripheral.name ?? "未知")")
        case .failed(let peripheral, let error):
            print("连接失败: \(peripheral.name ?? "未知")，错误: \(error?.localizedDescription ?? "无")")
        case .timedOut(let peripheral):
            print("连接超时: \(peripheral.name ?? "未知")")
        case .disconnected(let peripheral, let reason):
            switch reason {
            case .userInitiated:
                print("用户主动断开设备: \(peripheral.name ?? "未知")")
            case .unexpected(let error):
                print("设备异常断开: \(peripheral.name ?? "未知")，错误: \(error.localizedDescription)")
            }
        case .onReady(let result):
            switch result {
            case .success(let peripheral, _):
                print("通道准备就绪: \(peripheral.name ?? "未知")")
                
                let cmd = ["AA", "55", "00", "F0", "04", "AA", "55", "11", "00", "FC"].map { UInt8($0, radix: 16)! }
                bleManager.wirteData(Data(cmd), for: peripheral)
            case .failure(let peripheral, let error):
                print("通道准备失败: \(peripheral.name ?? "未知")，错误: \(error.localizedDescription)")
            }
        }
    }
    .onReconnectPhase { peripheral, state in
        switch state {
        case .started:
            print("重连开始: \(peripheral.name ?? "未知")")
        case .stopped(let result):
            print("重连停止: \(result == .success ? "成功" : "超时")")
        }
    }
    .setOnWithResponseWriteResult { result in
        switch result {
        case .success(let peripheral, _):
            print("写入成功: \(peripheral.name ?? "未知")")
        case .failure(let peripheral, _, let error):
            print("写入失败: \(peripheral.name ?? "未知"), Error: \(error.localizedDescription)")
        }
    }
    .setOnDataReceived { result in
        // 仅有成功的情况
        if case let .success(peripheral, _, data) = result {
            let hex = data.map { String(format: "%02X", $0) }
            print("收到数据: \(peripheral.name ?? "未知"). \(hex)")
        }
    }
    .setCmdComparisonRule { cmdData, ackData in
        let reqData = cmdData.data
        let success = reqData[0] == ackData[0] && reqData[1] == ackData[1] && reqData[3] == ackData[3]
        print("比较: \(success ? "成功" : "失败"), \(success ? "" : "\(reqData[3]) != \(ackData[3])")")
        return success
    }
    .setWriteTimeoutHandle { data in
        print("写入超时处理: \(data.uuid). \(data.requestId.uuidString)")
    }

```

#### 5. rx订阅

```swift
bleManager.rx.managerStateUpdate().subscribe(onNext: { state in
    print("蓝牙状态更新: \(state.rawValue)")
}).disposed(by: rx.disposeBag)

bleManager.rx.scanStateUpdate().subscribe(onNext: { [weak self] state in
    guard let self = self else { return }
    print("扫描状态更新: \(state)")
    switch state {
    case .started:
        break
    case .stopped:
        print("扫描完成. 共发现 \(self.peripherals.count) 个外设, 共: \(self.bleManager.discoveredPeripherals.map({ $0.name ?? "未知" }))")
    }
}).disposed(by: rx.disposeBag)

bleManager.rx.peripheralDiscoveredWithParser().subscribe(onNext: { [weak self] (peripheral, pDataProvider, parse: String?) in
    guard let self = self else { return }
    if let data = parse, let manufacturerData = pDataProvider.advertisementData["kCBAdvDataManufacturerData"] as? Data {
        let manufacturerBytes = [UInt8](manufacturerData).map({String(format: "%02x", $0).uppercased()})
        print("指定发现外设: \(peripheral.name ?? "未知") 广播包: \(manufacturerBytes) 信号: \(pDataProvider.rssi) 解析Mac地址: \(data)")
        self.peripherals.append(peripheral)
        self.listView.reloadData()
    }
}).disposed(by: rx.disposeBag)

bleManager.rx.connectStateUpdate().subscribe(onNext: { [weak self] state, peripheral in
    guard let self = self else { return }
    self.updatePreipherals(with: peripheral)
    switch state {
    case .connecting(let peripheral):
        print("连接中: \(peripheral.name ?? "未知")")
    case .connected(let peripheral):
        print("连接成功: \(peripheral.name ?? "未知")")
    case .failed(let peripheral, let error):
        print("连接失败: \(peripheral.name ?? "未知")，错误: \(error?.localizedDescription ?? "无")")
    case .timedOut(let peripheral):
        print("连接超时: \(peripheral.name ?? "未知")")
    case .disconnected(let peripheral, let reason):
        switch reason {
        case .userInitiated:
            print("用户主动断开设备: \(peripheral.name ?? "未知")")
        case .unexpected(let error):
            print("设备异常断开: \(peripheral.name ?? "未知")，错误: \(error.localizedDescription)")
        }
    case .onReady(let result):
        switch result {
        case .success(let peripheral, _):
            print("通道准备就绪: \(peripheral.name ?? "未知")")
            
            let cmd = ["AA", "55", "00", "F0", "04", "AA", "55", "11", "00", "FC"].map { UInt8($0, radix: 16)! }
            bleManager.wirteData(Data(cmd), for: peripheral)
        case .failure(let peripheral, let error):
            print("通道准备失败: \(peripheral.name ?? "未知")，错误: \(error.localizedDescription)")
        }
    }
}).disposed(by: rx.disposeBag)

bleManager.rx.reconnectPhaseUpdate().subscribe(onNext: { peripheral, state in
    switch state {
    case .started:
        print("重连开始: \(peripheral.name ?? "未知")")
    case .stopped(let result):
        print("重连停止: \(result == .success ? "成功" : "超时")")
    }
}).disposed(by: rx.disposeBag)

bleManager.rx.dataReceived().subscribe(onNext: { result in
    // 仅有成功的情况
    if case let .success(peripheral, _, data) = result {
        let hex = data.map { String(format: "%02X", $0) }
        print("收到数据: \(peripheral.name ?? "未知"). \(hex)")
    }
}).disposed(by: rx.disposeBag)

bleManager.rx.writeTimeout().subscribe(onNext: { data in
    print("写入超时处理: \(data.uuid). \(data.description)")
}).disposed(by: rx.disposeBag)
```
