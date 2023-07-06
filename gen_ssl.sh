#!/bin/sh

#  gen_ssl.sh
#  libPaho
#
#  Created by Jo on 2023/7/3.
#  

function LOG {
    echo ">> $1"
}

START_TIME=$(date +%s)

# 清理资源
LOG "Clear Resources ..."
rm -rf ssl_build
mkdir ssl_build
mkdir ssl_build/x86_64
mkdir ssl_build/arm64

# 新建一个临时的编译目录
SSL_BUILD_FOLD=$(pwd)/ssl_build

SSL_TAR_FILE=$(find . -type f -name 'openssl*.tar.gz')
if [ -z $SSL_TAR_FILE ]; then
    LOG "openssl tar file not found"
    exit 0
fi
LOG "find tar $SSL_TAR_FILE"

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
    tar -xzf $SSL_TAR_FILE
    
    SSL_SOURCE_FOLD=$(find . -type d -name 'openssl-*')
    if [ -z $SSL_SOURCE_FOLD ]; then
        LOG "openssl source foler not found"
        exit 0
    fi
    LOG "find openssl folder $SSL_SOURCE_FOLD"
    cd $SSL_SOURCE_FOLD
    
    #
    # 设置一下编译选项，其中需要注意 no-asm 参数。
    #
    # 在编译 OpenSSL 时，no-asm 是一个配置选项，用于禁用特定平台的汇编优化。
    # 下面是关于 no-asm 的一些重要信息：
    # 1. 汇编优化：OpenSSL 使用汇编语言来实现某些算法的优化，以提高性能。这些汇编代码通常是针对
    #   特定的处理器架构和操作系统优化的。
    # 2. no-asm 选项：使用 no-asm 配置选项可以禁用 OpenSSL 中的汇编优化。这意味着在编译过程
    #   中不会使用汇编代码来进行性能优化。通常情况下，禁用汇编优化可以增加可移植性，但可能会导致
    #   性能下降。
    # 3. 使用 no-asm 的情况：
    #   - 平台不支持汇编优化：某些平台可能不支持或不兼容特定的汇编优化。在这种情况下，
    #     使用 no-asm 可以确保 OpenSSL 能够在该平台上正常编译和运行，尽管性能可能会受到影响。
    #   - 架构兼容性问题：如果您计划在不同的架构上使用相同的编译结果，可以使用 no-asm 以确保生
    #     成的代码在不同架构之间具有更好的可移植性。
    # 4. 默认情况：通常情况下，no-asm 并不是默认启用的，因为汇编优化可以提供显著的性能提升。
    #   默认情况下，OpenSSL 会尝试使用汇编优化来提高性能。
    #
    # 综上所述，使用 no-asm 配置选项可以在编译 OpenSSL 时禁用汇编优化。这可能是出于可移植性或
    # 平台兼容性的考虑。但请注意，禁用汇编优化可能会导致性能下降。在实际使用中，您可以根据您的需
    # 求和目标平台选择是否启用或禁用 no-asm 选项。
    ./Configure $1 --prefix=$SSL_BUILD_FOLD/$2 no-shared no-asm
    
    # 编译
    make
    make install
    cd ..

    rm -rf $SSL_SOURCE_FOLD
}

ARCH_BUILD darwin64-arm64 arm64
ARCH_BUILD darwin64-x86_64-cc x86_64

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
lipo -create $ARM64_SSL $X86_64_SSL       -output ./libssl/lib/libssl.a
lipo -create $ARM64_CRYPTO $X86_64_CRYPTO -output ./libssl/lib/libcrypto.a

# 移动头文件
mv $SSL_BUILD_FOLD/arm64/include ./libssl/include

rm -rf $SSL_BUILD_FOLD

END_TIME=$(date +%s)
EXEC_DURATION=$((END_TIME - START_TIME))
LOG ""
LOG "Build openssl in $EXEC_DURATION seconds."
LOG ""
