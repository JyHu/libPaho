Pod::Spec.new do |s|
  s.name        = "libPahoA"
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
  
  s.source_files = "libPahoA/*.h"
  s.vendored_libraries = "libPahoA/libpaho-mqtt3a.a"
end
