#!/bin/sh

#  gen_paho.sh
#  Paho
#
#  Created by Jo on 2023/6/29.
#

function LOG {
    echo ""
    echo ">> $1"
}

START_TIME=$(date +%s)

CUR_FOLDER=$(pwd)

# 清理资源
LOG "rm -rf tmp && mkdir tmp && cd tmp"
rm -rf tmp && mkdir tmp && cd tmp

# 下载最新的代码
LOG "git clone https://github.com/eclipse/paho.mqtt.c ./"
git clone https://github.com/eclipse/paho.mqtt.c ./

# 新建一个临时的编译目录
LOG "mkdir build && cd build"
rm -rf build
mkdir build && cd build

# 生成make资源
echo $OPENSSL_ROOT_DIR
LOG "cmake .."
cmake -DPAHO_BUILD_SHARED=FALSE             \
    -DPAHO_BUILD_STATIC=TRUE                \
    -DPAHO_HIGH_PERFORMANCE=TRUE            \
    -DPAHO_WITH_SSL=TRUE                    \
    -DPAHO_ENABLE_TESTING=FALSE             \
    -DOPENSSL_ROOT_DIR="$CUR_FOLDER/libssl" \
    -DOPENSSL_INCLUDE_DIR="$CUR_FOLDER/libssl/include" \
    -DOPENSSL_LIBRARIES="$CUR_FOLDER/libssl/lib"    \
    -DCMAKE_BUILD_TYPE=Release                      \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"        \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="10.12"           \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON ..

# 开始打包
LOG "make"
make

# 移动打包资源
cd ../../
rm -rf libPahoC/libs
mkdir libPahoC/libs

# 检查需要的.a资源是否存在
function CHECK_LIB {
    LOG "Check $1"
    LIB_FILE="./tmp/build/src/$1"
    
    if [ -f $LIB_FILE ]; then
        LIPO_INFO=$(lipo -info $LIB_FILE)
        
        if [[ $LIPO_INFO =~ "x86_64" ]] && [[ $LIPO_INFO =~ "arm64" ]]; then
            echo "✅ $1 包含 x86_64 和 arm64"
            mv $LIB_FILE ./libPahoC/libs/$1
        else
            echo "❌ dylib 不包含 x86_64 和 arm64"
        fi
    else
        echo "❌ $1 file is not exists"
    fi
    
    echo ""
}

CHECK_LIB "libpaho-mqtt3a.a"
CHECK_LIB "libpaho-mqtt3as.a"
CHECK_LIB "libpaho-mqtt3c.a"
CHECK_LIB "libpaho-mqtt3cs.a"

# 清理资源
LOG "rm -rf tmp"
rm -rf tmp


END_TIME=$(date +%s)
EXEC_DURATION=$((END_TIME - START_TIME))
LOG ""
LOG "Build pahoc in $EXEC_DURATION seconds."
LOG ""
