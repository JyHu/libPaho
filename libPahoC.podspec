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
  
  s.source_files = "libPaho/*.h"
    
  s.subspec '3a' do |ss|
    ss.vendored_libraries = "libPaho/libpaho-mqtt3a.a"
  end
 
  s.subspec '3as' do |ss|
    ss.vendored_libraries = "libPaho/libpaho-mqtt3as.a"
  end
  
  s.subspec '3c' do |ss|
    ss.vendored_libraries = "libPaho/libpaho-mqtt3c.a"
  end
 
  s.subspec '3cs' do |ss|
    ss.vendored_libraries = "libPaho/libpaho-mqtt3cs.a"
  end
  
end
