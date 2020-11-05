Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.name         = "HBSwiftKit"
  spec.version      = "0.0.8"
  spec.summary      = "Swift个人常用组件."
  spec.description  = <<-DESC
                仅仅一些个人常用组件.学习工作使用.
                   DESC
  spec.homepage     = "https://github.com/hubin97/HBSwiftKitExample"
  spec.swift_versions = ['5.0']

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.author             = { "Hubin_Huang" => "970216474@qq.com" }
  # spec.social_media_url   = "https://twitter.com/Hubin_Huang"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.platform     = :ios, "9.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.source       = { :git => "https://github.com/hubin97/HBSwiftKitExample.git", :tag => "#{spec.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  ###
  spec.source_files  = "HBSwiftKit/**/*.{h,m,swift}"

  spec.subspec 'Global' do |dd|
    dd.source_files  = "HBSwiftKit/Global/*"
  end
  
  spec.subspec 'Foundation' do |dd|
    dd.source_files  = "HBSwiftKit/Foundation/*"
  end
    
  spec.subspec 'UIKit' do |dd|
    dd.source_files  = "HBSwiftKit/UIKit/*"
    dd.dependency 'HBSwiftKit/Global'
    dd.dependency 'HBSwiftKit/Foundation'
  end
  
  spec.subspec 'BaseClass' do |dd|
    dd.source_files  = "HBSwiftKit/BaseClass/*"
    dd.dependency 'HBSwiftKit/Global'
    dd.dependency 'HBSwiftKit/Foundation'
    dd.dependency 'HBSwiftKit/UIKit'
  end

  spec.subspec 'Network' do |dd|
    dd.source_files  = "HBSwiftKit/Network/*"
    dd.dependency 'HBSwiftKit/Global'
    dd.dependency 'HBSwiftKit/Foundation'
    dd.dependency 'HBSwiftKit/UIKit'
  end

  spec.subspec 'Resources' do |dd|
    dd.source_files  = "HBSwiftKit/Resources/*"
  end

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # spec.resource  = "icon.png"
  ##spec.resources = ['HBSwiftKit/Resources/*.png']
  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"
  
  spec.resource_bundle = { 'HBSwiftKitResources' => 'HBSwiftKit/Resources/*.png' }

  #spec.resource_bundles = {
  #   'HBSwiftKitResources' => ['**/HBSwiftKit/Resources/*']
  #}

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
    spec.dependency "Kingfisher"
    
end
