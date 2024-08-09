#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

echo build_xerces.sh ==========================================================

source setenv.sh
source make.sh

if [[ $api -lt 28 ]]
then
  pushd iconv_source
  ./configure \
    --prefix=$GNU_ICONV_ROOT \
    --host=$target \
    "CC=${android_cc}" \
    "CXX=${android_cxx}" \
    "LD=${android_ld}" \
    CFLAGS="-fPIE -fPIC" \
    LDFLAGS="-pie"
  $make
  mkdir -p $GNU_ICONV_ROOT
  make install
  popd
fi

extra_configure_opts=()

if [ ! -z "${force_cpp_std+x}" ]
then
  extra_configure_opts+=("-DCMAKE_CXX_STANDARD=$force_cpp_std")
fi

pushd xerces_source
cmake \
  "-DCMAKE_INSTALL_PREFIX=$XERCESCROOT" \
  "-DCMAKE_TOOLCHAIN_FILE=$OPENDDS_ANDROID_NDK/build/cmake/android.toolchain.cmake" \
  "-DANDROID_ABI=$abi" "-DANDROID_PLATFORM=android-$api" \
  "-DANDROID_CPP_FEATURES=rtti exceptions" \
  "${extra_configure_opts[@]}"
$make
mkdir -p $XERCESCROOT
make install
popd
