set -e

mkdir -p xerces_build
dest=$(pwd)/xerces_build

source setenv.sh
source make.sh

cd xerces_source

cmake "-DCMAKE_INSTALL_PREFIX=$dest" "-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake" "-DANDROID_ABI=$abi" "-DANDROID_PLATFORM=android-$api" "-DANDROID_CPP_FEATURES=rtti exceptions"

$make
make install
