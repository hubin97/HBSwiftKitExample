#
# Be sure to run `pod lib lint HBSwiftKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
# SwifterSwift:  over 500 native Swift extensions https://github.com/SwifterSwift/SwifterSwift

#➜  HBSwiftKitExample (main) ✗ xcodebuild clean
#➜  HBSwiftKitExample (main) ✗ pod cache clean --all
#➜  HBSwiftKitExample (main) ✗ pod spec lint HBSwiftKit.podspec --allow-warnings --verbose

Pod::Spec.new do |s|
    
    # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.name             = 'Router'
    s.version          = '0.0.1'
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
    s.social_media_url = 'https://hubin97.github.io'
    
    # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.ios.deployment_target = '13.0'

    # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.source           = { :git => 'https://github.com/xxx.git', :tag => s.version.to_s }
    
    # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.source_files = 'Router/**/*'
    s.dependency 'HBSwiftKit'
    
    # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    #s.resource     = 'HBSwiftKit/HBSwiftKit.bundle'
    
    # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.requires_arc = true
    
end
