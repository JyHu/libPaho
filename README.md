# libPaho


依赖项目：
- eclipse.paho.c https://github.com/eclipse/paho.mqtt.c
- openssl https://www.openssl.org/source/


```
.
├── README.md
├── gen_paho.sh             编译pahoc的脚本
├── gen_ssl.sh              编译openssl的脚本
├── libPaho.xcodeproj
├── CocoaPaho               封装的libPahoC库
│   ├── CocoaPaho.h
│   ├── ......
│   ├── PahoTopic.h
│   └── PahoTopic.m
├── libPahoC                PahoC库
│   ├── headers             PahoC头文件
│   │   ├── Base64.h
│   │   ├── Clients.h
│   │   ├── Heap.h
│   │   └── ....h
│   └── libs
│       ├── libpaho-mqtt3a.a  异步包
│       ├── libpaho-mqtt3as.a 异步包+支持openssl
│       ├── libpaho-mqtt3c.a  同步包
│       └── libpaho-mqtt3cs.a 同步包+支持openssl
├── libPahoC.podspec
├── libssl                  openssl的资源文件和头文件
│   ├── include
│   │   └── openssl
│   │       ├── aes.h
│   │       ├── asn1.h
│   │       ├── asn1_mac.h
│   │       └── ....h
│   └── lib                 合并x86_64和arm64的静态库文件
│       ├── libcrypto.a
│       └── libssl.a
├── modulemap
│   └── cocoa_module.modulemap
├── openssl-3.1.1.tar.gz    openssl的源码资源
└── openssl_platforms

```

所有资源通过podfile引入，pod中支持4种paho资源的引入：

```

libPahoC
├── ssl             openssl
├── 3a              paho异步包
├── 3as             paho异步包+支持openssl
│   └── ssl         依赖openssl
├── 3c              paho同步包
├── 3cs             paho同步包+支持openssl
│   └── ssl         依赖openssl
│
├── CocoaPaho       封装的libPahoC库
├── Cocoa3a         异步包 
│   └── 3a
├── Cocoa3as        异步包支持openssl
│   └── 3as
│       └── ssl
├── Cocoa3c         同步包
│   └── 3c
└── Cocoa3cs        同步包支持openssl
    └── 3cs
        └── ssl

```

在项目中接入时需要以子仓库的形式引入，如:
`pod 'libPahoC/3as', :git => 'https://github.com/JyHu/libPaho'`
