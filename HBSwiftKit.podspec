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
  s.version          = '0.3.2'
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
  s.ios.deployment_target = '9.0'
  
  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source           = { :git => 'https://github.com/hubin97/HBSwiftKitExample.git', :tag => s.version.to_s }
  
  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #s.source_files  = 'HBSwiftKit/**/*.{h,m,swift}'
  s.subspec 'Global' do |ss|
      ss.source_files  = 'HBSwiftKit/Global/'
      ss.framework  = "Foundation", "UIKit"
  end
  
  s.subspec 'Extension' do |ss|
      ss.source_files  = 'HBSwiftKit/Extension/'
      ss.dependency 'HBSwiftKit/Global'
  end
  
  s.subspec 'Base' do |ss|
      ss.source_files  = 'HBSwiftKit/Base/'
      ss.dependency 'HBSwiftKit/Global'
      ss.dependency 'HBSwiftKit/Extension'
  end
  
  s.subspec 'UIKit' do |ss|
      ss.source_files  = 'HBSwiftKit/UIKit/**/*'
      ss.dependency 'HBSwiftKit/Global'
      ss.dependency 'HBSwiftKit/Extension'
      ss.dependency 'HBSwiftKit/Base'
  end
  
  s.subspec 'Network' do |ss|
      ss.source_files  = 'HBSwiftKit/Network/'
      ss.dependency 'HBSwiftKit/Global'
      ss.dependency 'HBSwiftKit/Extension'
      ss.dependency 'HBSwiftKit/UIKit'
  end
  
  s.subspec 'Tools' do |ss|
      ss.source_files  = 'HBSwiftKit/Tools/'
      ss.dependency 'HBSwiftKit/Global'
      ss.dependency 'HBSwiftKit/UIKit'
  end
  
#  s.subspec 'Assets' do |dd|
#    dd.source_files  = "HBSwiftKit/Assets/*"
#  end

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.resource     = 'HBSwiftKit/HBSwiftKit.bundle'
#  s.resource_bundles = {
#      'HBSwiftKit' => ['HBSwiftKit/Assets/*.png']
#  }

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true
  # test -- 
  #s.static_framework = true

end
