#!/bin/sh

#  generate.sh
#  Paho
#
#  Created by Jo on 2023/6/29.
#

function LOG {
    echo ""
    echo ">> $1"
}

LOG "rm -rf tmp && mkdir tmp && cd tmp"
#rm -rf tmp && mkdir tmp && cd tmp
cd tmp

LOG "git clone https://github.com/eclipse/paho.mqtt.c ./"
#git clone https://github.com/eclipse/paho.mqtt.c ./

sed -e 's/PAHO_BUILD_SHARED\ TRUE/PAHO_BUILD_SHARED\ FALSE/g' \
    -e 's/PAHO_BUILD_STATIC\ FALSE/PAHO_BUILD_STATIC\ TRUE/g' \
    -e 's/PAHO_ENABLE_TESTING\ TRUE/PAHO_ENABLE_TESTING\ FALSE/g' "./CMakeLists.txt" > "./CMakeLists_Modify.txt"
mv ./CMakeLists_Modify.txt ./CMakeLists.txt

LOG "mkdir build && cd build"
rm -rf build
mkdir build && cd build

export CMAKE_OSX_ARCHITECTURES="arm64;x86_64"
export OPENSSL_ROOT_DIR="/usr/local/Cellar/openssl@3/3.1.1_1"

echo $OPENSSL_ROOT_DIR
LOG "cmake .."
cmake -DPAHO_WITH_SSL=TRUE -DPAHO_BUILD_DOCUMENTATION=FALSE -DPAHO_BUILD_SAMPLES=FALSE ..
#cmake ..


LOG "make"
make

cd ../../

function CHECK_LIB {
    LOG "Check $1"
    LIB_FILE="./tmp/build/src/$1"
    
    if [ -f $LIB_FILE ]; then
        LIPO_INFO=$(lipo -info $LIB_FILE)
        
        if [[ $LIPO_INFO =~ "x86_64" ]] && [[ $LIPO_INFO =~ "arm64" ]]; then
            echo "✅ $1 包含 x86_64 和 arm64"
            mv $LIB_FILE ./libPaho/$1
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

LOG "rm -rf tmp"
rm -rf tmp

echo ""

