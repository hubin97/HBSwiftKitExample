// MARK: 沙盒
import UIKit
public class AppSandbox: NSObject {

    static let shared = AppSandbox()

    /// 禁止外部调用init初始化方法
    private override init() {
        super.init()
    }

    /// 获取程序的Home目录
    var homeDirectory: String {
        let path = NSHomeDirectory()
        return path
    }

    /// Documents 目录：您应该将所有的应用程序数据文件写入到这个目录下。这个目录用于存储用户数据。该路径可通过配置实现iTunes共享文件。可被iTunes备份。
    var documentDirectory: String {

        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return ""
        }
        return path
    }

    /// 获取Library目录
    /*
     * Library 目录：这个目录下有两个子目录：
     * Preferences 目录：包含应用程序的偏好设置文件。您不应该直接创建偏好设置文件，而是应该使用NSUserDefaults类来取得和设置应用程序的偏好.
     * Caches 目录：用于存放应用程序专用的支持文件，保存应用程序再次启动过程中需要的信息。
     * 可创建子文件夹。可以用来放置您希望被备份但不希望被用户看到的数据。该路径下的文件夹，除Caches以外，都会被iTunes备份。
     */
    var libraryDirectory: String {
        guard let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            return ""
        }
        return path
    }

    /// Caches 目录：用于存放应用程序专用的支持文件，保存应用程序再次启动过程中需要的信息。
    var cachesDirectory: String {
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            return ""
        }
        return path
    }

    /// tmp目录：这个目录用于存放临时文件，保存应用程序再次启动过程中不需要的信息。该路径下的文件不会被iTunes备份。
    var tmpDirectory: String {

        let path = NSTemporaryDirectory()
        return path
    }
}

public extension App {
    /// 缓存路径
    var  cachePath: String {
        return AppSandbox.shared.cachesDirectory + "/" + "AppSpeedyCache"
    }
    /// Set 缓存数据
    func asyncSetCache(jsonResponse: AnyObject, URL: String, subPath: String?, completed:@escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            let result = self.setCache(jsonResponse, URL: URL, subPath: subPath)
            DispatchQueue.main.async(execute: {
                completed(result)
            })
        }
    }

    /// 写入/更新缓存(同步) [按APP版本号缓存,不同版本APP,同一接口缓存数据互不干扰]
    func setCache(_ jsonResponse: AnyObject, URL: String, subPath: String?) -> Bool {
        lock.wait()
        let data = (jsonResponse as? [String: Any])?.jsonData()
        let atPath = getCacheFilePath(url: URL, subPath: subPath)
        let isSuccess = FileManager.default.createFile(atPath: atPath, contents: data, attributes: nil)
        lock.signal()
        return isSuccess
    }
    /// Get  获取数据
    func getCacheJsonWithURL(_ URL: String, subPath: String = "") -> AnyObject? {
        lock.wait()
        var resultObject: AnyObject?
        let path = getCacheFilePath(url: URL, subPath: subPath)
        let fileManager: FileManager = FileManager.default
        if fileManager.fileExists(atPath: path, isDirectory: nil) == true {
            let data: Data = fileManager.contents(atPath: path)!
            resultObject = try? data.jsonObject() as AnyObject
        }
        lock.signal()
        return resultObject
    }

    /// 获取缓存文件路径
    fileprivate func getCacheFilePath(url: String, subPath: String?) -> String {
        var newPath: String = self.cachePath

        if let tempSubPath = subPath, !tempSubPath.isEmpty {
            newPath = self.cachePath + "/" + tempSubPath
        }

        self.checkDirectory(newPath)
        // check路径
        let cacheFileNameString: String = "URL:\(url) AppVersion:\(App.version ?? "")"
        let cacheFileName: String = cacheFileNameString.md5
        newPath += ("/" + cacheFileName)
        return newPath
    }
    /// 检查文件夹
    fileprivate func checkDirectory(_ path: String) {
        let fileManager: FileManager = FileManager.default

        var isDir = ObjCBool(false) // isDir判断是否为文件夹
        if !fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            App.createBaseDirectoryAtPath(path)
        } else {
            if !isDir.boolValue {
                do {
                    try fileManager.removeItem(atPath: path)
                    App.createBaseDirectoryAtPath(path)
                } catch let error as NSError {
                    App.log("创建缓存文件夹失败，error - [\(error)]")
                }
            }
        }
    }
    /// 创建文件夹
    static func createBaseDirectoryAtPath(_ path: String) {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            self.addDoNotBackupAttribute(path)
        } catch let error as NSError {
            App.log("[缓存调试]-创建缓存文件夹失败！error[\(error)]")
        }
    }
    /// 设置不备份
    static func addDoNotBackupAttribute(_ path: String) {
        let url: URL = URL(fileURLWithPath: path)
        do {
            try  (url as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
        } catch let error as NSError {
            App.log("[缓存调试] - 设置不备份属性失败,error[\(error)]")
        }
    }
}
