set -e
source setenv.sh

extra_configure_flags=()

if $use_java
then
  if [ -z "${jdk}" ]
  then
    extra_configure_flags+=("--java")
  else
    extra_configure_flags+=("--java=${jdk}")
  fi
fi

if $use_security
then
  if $TRAVIS
  then
    bash build_xerces.sh &> /dev/null || echo "build_xerces.sh failed"
    bash build_openssl.sh &> /dev/null || echo "build_openssl.sh failed"
  else
    bash build_xerces.sh
    bash build_openssl.sh
  fi
  extra_configure_flags+=("--xerces3=${XERCESCROOT}" "--openssl=${SSL_ROOT}" --security)
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

if $use_oci_ace_tao
then
  extra_configure_flags+=("--macros=CPPFLAGS+=-Wno-deprecated-declarations")
fi

pushd $workspace/OpenDDS > /dev/null
./configure --target=android \
  --verbose \
  --ace=$ACE_ROOT \
  --tao=$TAO_ROOT \
  --tests \
  --no-inline \
  --macros=ANDROID_ABI:=$abi \
  "${extra_configure_flags[@]}"
popd > /dev/null

echo '#define ACE_DISABLE_MKTEMP' >> $ace_target/ace/config.h
echo '#define ACE_DISABLE_TEMPNAM' >> $ace_target/ace/config.h
echo '#if ACE_ANDROID_NDK_LESS_THAN(14, 0) || __ANDROID_API__ < 24' >> $ace_target/ace/config.h
echo '#  define ACE_LACKS_IF_NAMEINDEX' >> $ace_target/ace/config.h
echo '#endif' >> $ace_target/ace/config.h

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
