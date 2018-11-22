set -e
source setenv.sh

extra_configure_flags=()

if $use_java
then
  extra_configure_flags+=("--java=${workspace}/jdk")
fi

if $use_security
then
  extra_configure_flags+=("--xerces3=${workspace}/xerces_build" "--openssl=${workspace}/openssl_build --security")
fi

major_rev=$(echo $ndk | grep -oE '[0-9]+')
minor_rev=$(echo $ndk | grep -oE '[a-j]' | tr '[a-j]' '[0-9]')
if [ $major_rev -lt 16 ]
then
  extra_configure_flags+=("--macros=__NDK_MINOR__:=$minor_rev" "--macros=__NDK_MAJOR__:=$major_rev")
fi
if [ $major_rev -lt 15 ]
then
  extra_configure_flags+=("--macros=android_force_clang:=0")
fi

pushd $workspace/OpenDDS
./configure --no-tests --target=android \
  --ace=$ACE_ROOT \
  --tao=$TAO_ROOT \
  --macros=CPPFLAGS+=-Wno-deprecated \
  --macros=CPPFLAGS+=-Wno-deprecated-declarations \
  --no-inline \
  --macros=ANDROID_ABI:=$abi \
  "${extra_configure_flags[@]}" \
popd

if $build_ace_tests
then
  pushd $ace_target/tests
  mwc.pl -type gnuace tests.mwc
  popd
fi
