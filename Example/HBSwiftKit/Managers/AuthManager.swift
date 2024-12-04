//
//  AuthManager.swift
//  Momcozy
//
//  Created by hubin.h on 2024/5/13.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
//import KeychainAccess
import ObjectMapper
import RxSwift
import RxCocoa

/// 是否登录
let loggedIn = BehaviorRelay<Bool>(value: false)

// MARK: 项目内标识信息
enum AppKeys: String {
    case app_id
    case bundle_id
    case uid
    case email
    case password
    case token
    /// 记录选中地区
    case region
}

// MARK: - AuthManager
class AuthManager {

    static let shared = AuthManager()

    // MARK: - Properties
//    fileprivate let tokenKey = "TokenKey"
//    fileprivate let keychain = Keychain(service: AppKeys.bundle_id.identity)
    init() {
        loggedIn.accept(hasValidToken)
    }

    //FIXME: 暂时取消钥匙串方案
//    var token: LoginModel? {
//        get {
//            guard let jsonString = keychain[tokenKey] else { return nil }
//            return Mapper<LoginModel>().map(JSONString: jsonString)
//        }
//        set {
//            if let token = newValue, let jsonString = token.toJSONString() {
//                keychain[tokenKey] = jsonString
//            } else {
//                keychain[tokenKey] = nil
//            }
//        }
//    }
    
    var token: LoginModel? {
        get {
            guard let jsonString = UserDefaults.standard.string(forKey: AppKeys.token.rawValue) else { return nil }
            return Mapper<LoginModel>().map(JSONString: jsonString)
        }
        set {
            if let token = newValue, let jsonString = token.toJSONString() {
                UserDefaults.standard.set(jsonString, forKey: AppKeys.token.rawValue)
            } else {
                UserDefaults.standard.set(nil, forKey: AppKeys.token.rawValue)
            }
            UserDefaults.standard.synchronize()
        }
    }

    /// Token 是否有效
    var hasValidToken: Bool {
        return token?.isValid == true
    }

    class func setToken(token: LoginModel) {
        AuthManager.shared.token = token
        //AuthManager.setTokenValid(true)
    }

    class func removeToken() {
        AuthManager.shared.token = nil
        //AuthManager.setTokenValid(false)
    }

    class func setTokenValid(_ isValid: Bool) {
        AuthManager.shared.token?.isValid = isValid
        loggedIn.accept(isValid)
    }
}

// MARK: 补充用户信息
extension AuthManager {
    
    var uid: String? {
        get {
            UserDefaults.standard.string(forKey: AppKeys.uid.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppKeys.uid.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    var email: String? {
        get {
            UserDefaults.standard.string(forKey: AppKeys.email.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppKeys.email.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// 注意`base64加密存取`
    var password: String? {
        get {
            UserDefaults.standard.string(forKey: AppKeys.password.rawValue)?.base64Decode()
        }
        set {
            UserDefaults.standard.set(newValue?.base64Encode(), forKey: AppKeys.password.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    class func setUid(_ uid: String?) {
        AuthManager.shared.uid = uid
    }
    
    class func setEmail(_ email: String?) {
        AuthManager.shared.email = email
    }
    
    class func setPassword(_ password: String?) {
        AuthManager.shared.password = password
    }

    class func removeUid() {
        AuthManager.shared.uid = nil
    }
    
    class func removeUserInfo() {
        AuthManager.shared.uid = nil
        AuthManager.shared.email = nil
        AuthManager.shared.password = nil
    }
}

// MARK: - LoginModel
struct LoginModel: Mappable {
    init?(map: ObjectMapper.Map) {}
    
    mutating func mapping(map: ObjectMapper.Map) {
        uid <- map["uid"]
        token <- map["token"]
        refreshToken <- map["refreshToken"]
        shopifyLoginToken <- map["shopifyLoginToken"]
        expire <- map["expire"]
        
        isValid <- map["isValid"]
    }
    var uid: String?
    var token: String?
    var refreshToken: String?
    var shopifyLoginToken: String?
    var expire: Int?
    
    // 是否有效
    var isValid = false
}
