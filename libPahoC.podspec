Pod::Spec.new do |s|
  s.name        = "libPahoC"
  s.version     = "0.1.0"
  s.summary     = "MQTT client library for iOS and OS X"
  s.homepage    = "https://github.com/JyHu/libPaho"
  s.license     = { :type => "MIT" }
  s.authors     = { "Jo" => "auu.aug@gmail.com"}

  s.swift_version = "5.0"
  s.requires_arc = true
  s.osx.deployment_target = "10.12"
  s.ios.deployment_target = "11.0"
  s.source   = { :git => "https://github.com/JyHu/libPaho.git", :tag => '0.1.0' }
  
  #
  # ============================================================================
  #
  #                         编译的openssl+libPahoC框架
  #
  # ============================================================================
  #
  
  # 异步包
  s.subspec '3a' do |ss|
    ss.source_files = "libPahoC/headers/*.h"
    ss.vendored_libraries = "libPahoC/libs/libpaho-mqtt3a.a"
  end
 
  # 异步包+支持openssl
  s.subspec '3as' do |ss|
    ss.source_files = "libPahoC/headers/*.h"
    ss.dependency "libPahoC/ssl"
    ss.vendored_libraries = "libPahoC/libs/libpaho-mqtt3as.a"
    ss.xcconfig = {
        "GCC_PREPROCESSOR_DEFINITIONS" => 'PAHOC_ENABLE_SSL_CONNECTION=1'
    }
  end
  
  # 同步包
  s.subspec '3c' do |ss|
    ss.source_files = "libPahoC/headers/*.h"
    ss.vendored_libraries = "libPahoC/libs/libpaho-mqtt3c.a"
  end
 
  # 同步包+支持openssl
  s.subspec '3cs' do |ss|
    ss.source_files = "libPahoC/headers/*.h"
    ss.dependency "libPahoC/ssl"
    ss.vendored_libraries = "libPahoC/libs/libpaho-mqtt3cs.a"
    ss.xcconfig = {
      "GCC_PREPROCESSOR_DEFINITIONS" => 'PAHOC_ENABLE_SSL_CONNECTION=1'
    }
  end
  
  # 异步paho需要的openssl依赖
  s.subspec 'ssl' do |ss|
    ss.source_files = "libssl/include/**/*.h"
    ss.vendored_libraries = "libssl/lib/*.a"
  end
  
  #
  # ============================================================================
  #
  #                         使用OC封装的libPahoC框架
  #
  # ============================================================================
  #
  
  # 使用oc封装的libPahoC库
  s.subspec 'CocoaPaho' do |ss|
    ss.source_files = "CocoaPaho/*.{h,m}", "modulemap/cocoa_module.modulemap"
  end
  
  # 异步包+cocoa封装
  s.subspec 'Cocoa3a' do |ss|
    ss.dependency "libPahoC/3a"
    ss.dependency "libPahoC/CocoaPaho"
    s.module_map = "modulemap/cocoa_module.modulemap"
  end
 
  # 异步包+支持openssl+cocoa封装
  s.subspec 'Cocoa3as' do |ss|
    ss.dependency "libPahoC/3as"
    ss.dependency "libPahoC/CocoaPaho"
    s.module_map = "modulemap/cocoa_module.modulemap"
  end
  
  # 同步包+cocoa封装
  s.subspec 'Cocoa3c' do |ss|
    ss.dependency "libPahoC/3c"
    ss.dependency "libPahoC/CocoaPaho"
    s.module_map = "modulemap/cocoa_module.modulemap"
  end
 
  # 同步包+支持openssl+cocoa封装
  s.subspec 'Cocoa3cs' do |ss|
    ss.dependency "libPahoC/3cs"
    ss.dependency "libPahoC/CocoaPaho"
    s.module_map = "modulemap/cocoa_module.modulemap"
  end
end
