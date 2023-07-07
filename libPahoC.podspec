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
  
  s.subspec 'client' do |ss|
    ss.source_files = "client/*.h"
  end
  
  # 异步包
  s.subspec '3a' do |ss|
    ss.source_files = "libPahoC/headers/*.h"
    ss.dependency "libPahoC/client"
    ss.vendored_libraries = "libPahoC/libs/libpaho-mqtt3a.a"
  end
 
  # 异步包+支持openssl
  s.subspec '3as' do |ss|
    ss.source_files = "libPahoC/headers/*.h"
    ss.dependency "libPahoC/ssl"
    ss.dependency "libPahoC/client"
    ss.vendored_libraries = "libPahoC/libs/libpaho-mqtt3as.a"
  end
  
  # 同步包
  s.subspec '3c' do |ss|
    ss.source_files = "libPahoC/headers/*.h"
    ss.dependency "libPahoC/client"
    ss.vendored_libraries = "libPahoC/libs/libpaho-mqtt3c.a"
  end
 
  # 同步包+支持openssl
  s.subspec '3cs' do |ss|
    ss.source_files = "libPahoC/headers/*.h"
    ss.dependency "libPahoC/ssl"
    ss.dependency "libPahoC/client"
    ss.vendored_libraries = "libPahoC/libs/libpaho-mqtt3cs.a"
  end
  
  # 异步paho需要的openssl依赖
  s.subspec 'ssl' do |ss|
    ss.source_files = "libssl/include/**/*.h"
    ss.vendored_libraries = "libssl/lib/*.a"
    ss.dependency "libPahoC/client"
  end
end
