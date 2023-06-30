#!/bin/sh

#  generate.sh
#  Paho
#
#  Created by Jo on 2023/6/29.
#

function LOG {
    echo ""
    echo "$1 ..."
}

LOG "rm -rf tmp && mkdir tmp && cd tmp"
rm -rf tmp && mkdir tmp && cd tmp

LOG "git clone https://github.com/eclipse/paho.mqtt.c ./"
git clone https://github.com/eclipse/paho.mqtt.c ./

sed -e 's/PAHO_BUILD_SHARED\ TRUE/PAHO_BUILD_SHARED\ FALSE/g' -e 's/PAHO_BUILD_STATIC\ FALSE/PAHO_BUILD_STATIC\ TRUE/g' "./CMakeLists.txt" > "./CMakeLists_Modify.txt"
mv ./CMakeLists_Modify.txt ./CMakeLists.txt

LOG "mkdir build && cd build"
mkdir build && cd build

export CMAKE_OSX_ARCHITECTURES="arm64;x86_64"

LOG "cmake .."
cmake ..

LOG "make"
make

LIPO_INFO=$(lipo -info ./src/libpaho-mqtt3a.a)

echo ""

if [[ $LIPO_INFO =~ "x86_64" ]] && [[ $LIPO_INFO =~ "arm64" ]]; then
    echo "✅ dylib 包含 x86_64 和 arm64"
    cd ../../
    
    if [ -f tmp/build/src/libpaho-mqtt3a.a ]; then
#        rm -rf ./Paho/lib
#        mkdir ./Paho/lib
        LOG "mv tmp/build/src/libpaho-mqtt3a.a ./Paho/lib/libpaho-mqtt3a.a"
        mv tmp/build/src/libpaho-mqtt3a.a ./libPahoA/libpaho-mqtt3a.a
#        mv tmp/src/*.h ./Paho/lib
    else
        echo "❌ .a file is not exists"
    fi
else
    echo "❌ dylib 不包含 x86_64 和 arm64"
fi

LOG "rm -rf tmp"
rm -rf tmp

echo ""

