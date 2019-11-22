set -e
source setenv.sh

extra_configure_flags=()

if $use_java
then
  extra_configure_flags+=("--java=${workspace}/jdk")
fi

if $use_security
then
  if $TRAVIS
  then
    travis_wait 20 bash build_xerces.sh &> /dev/null || echo "build_xerces.sh failed"
    travis_wait 15 bash build_openssl.sh &> /dev/null || echo "build_openssl.sh failed"
  else
    bash build_xerces.sh
    bash build_openssl.sh
  fi
  extra_configure_flags+=("--xerces3=${workspace}/xerces_build" "--openssl=${workspace}/openssl_build" --security)
fi

if [ ! -z "${host_tools}" ]
then
  extra_configure_flags+=("--host-tools=$host_tools" "--no-tests")
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

pushd $workspace/OpenDDS > /dev/null
./configure --target=android \
  --ace=$ACE_ROOT \
  --tao=$TAO_ROOT \
  --tests \
  --macros=CPPFLAGS+=-Wno-deprecated \
  --macros=CPPFLAGS+=-Wno-deprecated-declarations \
  --no-inline \
  --macros=ANDROID_ABI:=$abi \
  "${extra_configure_flags[@]}"
popd > /dev/null

if $build_ace_tests
then
  pushd $ace_target/tests > /dev/null
  old_ace_root="$ACE_ROOT"
  export ACE_ROOT="$ace_target"
  mwc.pl -type gnuace tests.mwc
  export ACE_ROOT="$old_ace_root"
  unset old_ace_root
  popd > /dev/null
fi
