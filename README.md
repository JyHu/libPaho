# libPaho


依赖项目：
- eclipse.paho.c https://github.com/eclipse/paho.mqtt.c
- openssl https://www.openssl.org/source/


```
├── gen_ssl.sh              编译openssl的脚本
├── generate.sh             编译pahoc的脚本
├── libPahoC                PahoC的资源文件头文件
│   ├── libpaho-mqtt3a.a    异步包
│   ├── libpaho-mqtt3as.a   异步包+支持openssl
│   ├── libpaho-mqtt3c.a    同步包
│   ├── libpaho-mqtt3cs.a   同步包+支持openssl
│   └── ....h
├── libPahoC.podspec
├── libssl                  openssl的资源文件和头文件
│   ├── include
│   │   └── openssl
│   │       └── .....h
│   └── lib
│       ├── libcrypto.a
│       └── libssl.a
└── openssl-3.1.1.tar.gz    openssl的源码资源
```

所有资源通过podfile引入，pod中支持4种paho资源的引入：

```
  # 异步包
  s.subspec '3a' do |ss|
    ss.source_files = "libPahoC/*.h"
    ss.vendored_libraries = "libPahoC/libpaho-mqtt3a.a"
  end
 
  # 异步包+支持openssl
  s.subspec '3as' do |ss|
    ss.source_files = "libPahoC/*.h"
    ss.dependency "libPahoC/ssl"
    ss.vendored_libraries = "libPahoC/libpaho-mqtt3as.a"
  end
  
  # 同步包
  s.subspec '3c' do |ss|
    ss.source_files = "libPahoC/*.h"
    ss.vendored_libraries = "libPahoC/libpaho-mqtt3c.a"
  end
 
  # 同步包+支持openssl
  s.subspec '3cs' do |ss|
    ss.source_files = "libPahoC/*.h"
    ss.dependency "libPahoC/ssl"
    ss.vendored_libraries = "libPahoC/libpaho-mqtt3cs.a"
  end
  
  # 异步paho需要的openssl依赖
  s.subspec 'ssl' do |ss|
    ss.source_files = "libssl/include/**/*.h"
    ss.vendored_libraries = "libssl/lib/*.a"
  end
```

在项目中接入时需要以子仓库的形式引入，如:
`pod 'libPahoC/3as', :git => 'https://github.com/JyHu/libPaho'`
