set -e

echo build_xerces.sh ==========================================================

source setenv.sh
source make.sh

if [[ $api -lt 28 ]]
then
  pushd iconv_source
  iconv_ld=${target}-ld
  if [ $ndk_major_rev -ge 22 ]
  then
    # ${target}-ld doesn't exist in r22. GNU linker is still there under
    # different names, but we should use LLVM linker.
    iconv_ld=$android_toolchain/bin/ld.lld
  fi
  ./configure \
    --prefix=$GNU_ICONV_ROOT \
    --host=$target \
    CC=${target}-clang \
    CXX=${target}-clang++ \
    LD=${iconv_ld} \
    CFLAGS="-fPIE -fPIC" \
    LDFLAGS="-pie"
  $make
  mkdir -p $GNU_ICONV_ROOT
  make install
  popd
fi

pushd xerces_source
cmake \
  "-DCMAKE_INSTALL_PREFIX=$XERCESCROOT" \
  "-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
  "-DANDROID_ABI=$abi" "-DANDROID_PLATFORM=android-$api" \
  "-DANDROID_CPP_FEATURES=rtti exceptions"
$make
mkdir -p $XERCESCROOT
make install
popd
