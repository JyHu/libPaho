#!/bin/sh

#  gen_ssl.sh
#  libPaho
#
#  Created by Jo on 2023/7/3.
#  

function LOG {
    echo ">> $1"
}

# 清理资源
LOG "Clear Resources ..."
rm -rf ssl_build
mkdir ssl_build
mkdir ssl_build/x86_64
mkdir ssl_build/arm64

# 新建一个临时的编译目录
SSL_BUILD_FOLD=$(pwd)/ssl_build
SSL_SOURCE_FOLD="openssl-1.1.1u"

echo $SSL_BUILD_FOLD

# 编译指定架构下的库
# $1 架构名
#   - darwin64-x86_64-cc
#   - darwin64-arm64-cc
# $2 文件夹名
#   - x86_64
#   - arm64
function ARCH_BUILD {
    LOG ""
    LOG "Build arch $1 ..."
    
    # 解压一下源代码压缩包
    tar -xzf openssl-1.1.1u.tar.gz
    cd $SSL_SOURCE_FOLD
    
    # 设置一下变量
    ./Configure $1 --prefix=$SSL_BUILD_FOLD/$2 no-shared
    
    # 编译
    make
    make install
    cd ..

    rm -rf $SSL_SOURCE_FOLD
}

ARCH_BUILD darwin64-x86_64-cc x86_64
ARCH_BUILD darwin64-arm64-cc arm64

ARM64_SSL="$SSL_BUILD_FOLD/arm64/lib/libssl.a"
X86_64_SSL="$SSL_BUILD_FOLD/x86_64/lib/libssl.a"
ARM64_CRYPTO="$SSL_BUILD_FOLD/arm64/lib/libcrypto.a"
X86_64_CRYPTO="$SSL_BUILD_FOLD/x86_64/lib/libcrypto.a"

# 校验打包资源有效性
if [ ! -f $ARM64_SSL ]; then
    LOG "$ARM64_SSL not found"
    exit 0
fi

if [ ! -f $ARM64_CRYPTO ]; then
    LOG "$ARM64_CRYPTO not found"
    exit 0
fi

if [ ! -f $X86_64_SSL ]; then
    LOG "$X86_64_SSL not found"
    exit 0
fi

if [ ! -f $X86_64_CRYPTO ]; then
    LOG "$X86_64_CRYPTO not found"
    exit 0
fi

# 移除旧的编译的包
rm -rf libssl
mkdir libssl
mkdir libssl/lib

# 合并x86_64 arm64架构的.a为一个文件
lipo -create $ARM64_SSL $X86_64_SSL -output ./libssl/lib/libssl.a
lipo -create $ARM64_CRYPTO $X86_64_CRYPTO -output ./libssl/lib/libcrypto.a

# 移动头文件
mv $SSL_BUILD_FOLD/arm64/include ./libssl/include

rm -rf $SSL_BUILD_FOLD
