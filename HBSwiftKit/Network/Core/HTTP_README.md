# HTTP

### 组件架构
基于 Moya + PromiseKit + ObjectMapper + ProgressHUD 搭建

### 使用说明
```
 1. 
 /// 全局网络处理
 class NetworkResponseHandler: NetworkHandleProvider {
    func successHandle(dismiss: Bool, response: Response) {}
 }
 
 2.
 /// 扩展插件方法
 extension PTEnum {
     /// 所有插件
     public static func all(content: String? = nil, isEnable: Bool = false, timeout: TimeInterval = 20) -> [PluginType] {
         return [PTEnum.loading(content: content, isEnable: isEnable), PTEnum.timeout(timeout), PTEnum.handle(provider: NetworkResponseHandler()), PTEnum.println()]
     }
     
     /// 排除loading 剩余的所有插件
     public static func noloadings(timeout: TimeInterval = 20) -> [PluginType] {
         return [PTEnum.timeout(timeout), PTEnum.handle(provider: NetworkResponseHandler()), PTEnum.println()]
     }
 }
```


### 使用示例

业务接口类 `AppInfoApi.swift`

```swift
import Foundation
import Moya

// MARK: - main class
enum AppInfoApi: TargetType {
    case appInfo(id: String, country: String?)
}

// MARK: - private mothods
extension AppInfoApi {
    
    // https://itunes.apple.com/lookup?id=xxx
    var path: String {
        switch self {
        case .appInfo:
            return "/lookup"
        }
    }
  
    var task: Moya.Task {
        switch self {
        case .appInfo(id: let id, country: let country):
            var params = ["id": id]
            if let country = country {
                params.setValue(country, forKey: "country")
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    var baseURL: URL {
        return URL(string: "https://itunes.apple.com")!
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            return ["Content-Type": "application/json; charset=utf-8"]
        }
    }
}
```

接口请求类 `AppInfoRequest.swift`

```swift
import Foundation
import PromiseKit
import ObjectMapper

func fetchAppInfo(id: String, country: String? = Locale.current.regionCode?.lowercased()) -> Promise<AppInfoModal> {
    return fetchTargetMeta(targetType: AppInfoApi.self, target: .appInfo(id: id, country: country), metaType: AppInfoModal.self, plugins: PTEnum.noloadings())
}

/// 版本比较, 有新版本时返回 true
/// - Parameter appModel: appstore请求的 详情信息
/// - Returns: bool
func versionCompare(_ appModel: AppInfoModal?) -> Bool {
    guard let resultCount = appModel?.resultCount, let appData = appModel?.results?.first, resultCount > 0 else { return false }
    guard let currVersion = kAppVersion, let lastVersion = appData.version else { return false }
    let currVersions = currVersion.split(separator: ".").compactMap({ Int($0) })
    let lastVersions = lastVersion.split(separator: ".").compactMap({ Int($0) })
    guard lastVersions.count == currVersions.count else { return true }

    for (curr, last) in zip(currVersions, lastVersions) {
        if last > curr {
            return true
        } else if last < curr {
            return false
        }
    }
    return false
}

// MARK: -
struct AppInfoModal: Mappable {
    init?(map: ObjectMapper.Map) {}
    
    mutating func mapping(map: ObjectMapper.Map) {
        results <- map["results"]
        resultCount <- map["resultCount"]
    }
    var resultCount: Int?
    var results: [AppInfoData]?
}

struct AppInfoData: Mappable {
    init?(map: ObjectMapper.Map) {}
    
    mutating func mapping(map: ObjectMapper.Map) {
        version <- map["version"]
        bundleId <- map["bundleId"]
        sellerName <- map["sellerName"]
        description <- map["description"]
        userRatingCount <- map["userRatingCount"]
    }
    
    var version: String?
    var bundleId: String?
    var sellerName: String?
    var description: String?
    var userRatingCount: Int?
    // ...
}
    
```

业务使用

```swift
func updateVersion() {
    fetchAppInfo(id: AppKeys.app_id.identity).done { appModel in
        // do something
    }.catch { error in
        print(error.localizedDescription)
    }
}
```