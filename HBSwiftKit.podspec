#
# Be sure to run `pod lib lint HBSwiftKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
# SwifterSwift:  over 500 native Swift extensions https://github.com/SwifterSwift/SwifterSwift

Pod::Spec.new do |s|
    
    # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.name             = 'HBSwiftKit'
    s.version          = '0.5.0'
    s.summary          = 'some common components.'
    s.description      = <<-DESC
    仅仅一些个人常用组件.学习工作使用.
    DESC
    s.homepage         = 'https://github.com/hubin97/HBSwiftKitExample'
    s.swift_versions = ['5.0']
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    
    # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    
    # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.author           = { 'Hubin_Huang' => '970216474@qq.com' }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.ios.deployment_target = '13.0'
    #s.pod_target_xcconfig = { 'IPHONEOS_DEPLOYMENT_TARGET' => '13.0' }
    #s.user_target_xcconfig = { 'IPHONEOS_DEPLOYMENT_TARGET' => '13.0' }

    # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.source           = { :git => 'https://github.com/hubin97/HBSwiftKitExample.git', :tag => s.version.to_s }
    
    # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    # 子模块：Base
    s.subspec 'Base' do |base|
        
        # 使用 Ruby 数组简化多个依赖的定义
        # 扩展自定义Hud;  pod 'ProgressHUD', :git => 'https://github.com/hubin97/ProgressHUD.git'
        ['SnapKit', 'Kingfisher', 'Toast-Swift', 'ProgressHUD'].each do |dd|
            base.dependency dd
        end
        #base.dependency 'Hero', '~> 1.6.3' # 确保使用支持 iOS 13 的版本

        base.subspec 'Global' do |ss|
            ss.source_files  = 'HBSwiftKit/Base/Global'
            ss.framework  = "Foundation", "UIKit"
        end
        
        base.subspec 'Extension' do |ss|
            ss.source_files  = 'HBSwiftKit/Base/Extension'
            ss.dependency 'HBSwiftKit/Base/Global'
        end
        
        base.subspec 'Base' do |ss|
            ss.source_files  = 'HBSwiftKit/Base/Base/'
            ss.dependency 'HBSwiftKit/Base/Extension'
        end
        
    end
    
    # 子模块：HTTP
    s.subspec 'HTTP' do |http|
        ['RxSwift', 'RxRelay', 'Moya', 'ObjectMapper', 'PromiseKit', 'ProgressHUD'].each do |dd|
            http.dependency dd
        end
        
        http.subspec 'Core' do |ss|
            ss.source_files  = 'HBSwiftKit/HTTP/Core/**/*.{swift,h,m,md}'
            ss.framework  = "Foundation"
        end
        
        http.subspec 'Utils' do |ss|
            ss.source_files  = 'HBSwiftKit/HTTP/Utils/**/*.swift'
            ss.framework  = "Foundation", "CoreTelephony"
        end
    end
    
    # 子模块：BLE
    s.subspec 'BLE' do |ble|
        ['RxSwift', 'RxCocoa', 'NSObject+Rx'].each do |dd|
            ble.dependency dd
        end
        
        ble.source_files  = 'HBSwiftKit/BLE/**/*.{swift,h,m,md}'
    end
    
    # 子模块：Other
    s.subspec 'Other' do |other|
        ['RxSwift', 'CocoaLumberjack'].each do |dd|
            other.dependency dd
        end
        
        other.source_files  = 'HBSwiftKit/Other/**/*'
        other.dependency 'HBSwiftKit/Base'
        
        other.subspec 'AuthStatus' do |sss|
            sss.source_files  = 'HBSwiftKit/Other/AuthStatus'
        end
        other.subspec 'LoggerManager' do |sss|
            sss.source_files  = 'HBSwiftKit/Other/LoggerManager'
        end
    end
    
    # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.resource     = 'HBSwiftKit/HBSwiftKit.bundle'
    
    # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.requires_arc = true
    
end
