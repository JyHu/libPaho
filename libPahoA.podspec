Pod::Spec.new do |s|
  s.name        = "libPahoA"
  s.version     = "1.0.0"
  s.summary     = "MQTT client library for iOS and OS X"
  s.homepage    = ""
  s.license     = { :type => "MIT" }
  s.authors     = { "Jo" => "auu.aug@gmail.com"}

  s.swift_version = "5.0"
  s.requires_arc = true
  s.osx.deployment_target = "10.12"
  s.ios.deployment_target = "11.0"
  s.tvos.deployment_target = "10.0"
  s.source   = { :git => "" }
  
  s.source_files = "libPahoA/*.h"
  ss.vendored_libraries = "libPahoA/libpaho-mqtt3a.a"
end