set -e

source setenv.sh
source make.sh

need_iconv=true
if [[ $api -ge 28 ]]
then
  pushd iconv_source
  ./configure \
    --prefix=$GNU_ICONV_ROOT\
    --host=$target \
    CC=${target}-${CC:-clang} \
    CXX=${target}-${CC:-clang++} \
    LD=${target}-${LD:-ld} \
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
