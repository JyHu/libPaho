Pod::Spec.new do |s|
  s.name        = "CocoaPaho"
  s.version     = "0.1.0"
  s.summary     = "MQTT client library for iOS and OS X"
  s.homepage    = "https://github.com/JyHu/libPaho"
  s.license     = { :type => "MIT" }
  s.authors     = { "Jo" => "auu.aug@gmail.com"}

  s.swift_version = "5.0"
  s.requires_arc = true
  s.osx.deployment_target = "10.12"
#  s.ios.deployment_target = "11.0"
  s.source   = { :git => "https://github.com/JyHu/libPaho.git", :tag => '0.1.0' }
  
  # 异步包
  s.subspec '3a' do |ss|
    ss.source_files = "CocoaPaho/*.{h,m}"
#    ss.dependency "libPahoC/3a"
  end
 
  # 异步包+支持openssl
  s.subspec '3as' do |ss|
    ss.source_files = "CocoaPaho/*.{h,m}"
#    ss.dependency "libPahoC/3as"
  end
  
  # 同步包
  s.subspec '3c' do |ss|
    ss.source_files = "CocoaPaho/*.{h,m}"
#    ss.dependency "libPahoC/3c"
  end
 
  # 同步包+支持openssl
  s.subspec '3cs' do |ss|
    ss.source_files = "CocoaPaho/*.{h,m}"
#    ss.dependency "libPahoC/3cs"
  end
end
