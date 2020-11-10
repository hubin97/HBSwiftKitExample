#
# Be sure to run `pod lib lint HBSwiftKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  
  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name             = 'HBSwiftKit'
  s.version          = '0.0.9'
  s.summary          = '个人常用组件.'
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
  s.ios.deployment_target = '9.0'
  
  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source           = { :git => 'https://github.com/hubin97/HBSwiftKitExample.git', :tag => s.version.to_s }
  
  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = 'HBSwiftKit/**/*.{h,m,swift}'
  s.subspec 'Global' do |dd|
    dd.source_files  = 'HBSwiftKit/Global/*.{h,m,swift}'
  end

  s.subspec 'Extension' do |dd|
    dd.source_files  = 'HBSwiftKit/Extension/*.{h,m,swift}'
    dd.dependency 'HBSwiftKit/Global'
  end

  s.subspec 'BaseClass' do |dd|
    dd.source_files  = 'HBSwiftKit/BaseClass/*.{h,m,swift}'
    dd.dependency 'HBSwiftKit/Global'
    dd.dependency 'HBSwiftKit/Extension'
  end

  s.subspec 'UIKit' do |dd|
    dd.source_files  = 'HBSwiftKit/UIKit/**/*'
    dd.dependency 'HBSwiftKit/Global'
    dd.dependency 'HBSwiftKit/Extension'
    dd.dependency 'HBSwiftKit/BaseClass'
  end

  s.subspec 'Network' do |dd|
    dd.source_files  = 'HBSwiftKit/Network/*'
    dd.dependency 'HBSwiftKit/Global'
    dd.dependency 'HBSwiftKit/Extension'
    dd.dependency 'HBSwiftKit/UIKit'
  end
  
#  s.subspec 'Assets' do |dd|
#    dd.source_files  = "HBSwiftKit/Assets/*"
#  end

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.resource_bundles = {
      'HBSwiftKit' => ['HBSwiftKit/Assets/*.png']
  }

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true
  s.dependency 'Kingfisher'

end
