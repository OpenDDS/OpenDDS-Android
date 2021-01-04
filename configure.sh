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
  extra_configure_flags+=("--macros=ANDROID_API_PATH=$ANDROID_SDK/platforms/android-$target_api")
fi

if $use_security
then
  bash build_xerces.sh
  bash build_openssl.sh
  extra_configure_flags+=("--xerces3=${XERCESCROOT}" "--openssl=${SSL_ROOT}" --security)
fi

if [ ! -z "${host_tools}" ]
then
  extra_configure_flags+=("--host-tools=$host_tools" "--no-tests")
fi

if [ $ndk_major_rev -lt 16 ]
then
  extra_configure_flags+=("--macros=__NDK_MINOR__:=$ndk_minor_rev" "--macros=__NDK_MAJOR__:=$ndk_major_rev")
fi
if [ $ndk_major_rev -lt 15 ]
then
  extra_configure_flags+=("--macros=android_force_clang:=0")
fi

if $use_oci_ace_tao
then
  extra_configure_flags+=("--macros=CPPFLAGS+=-Wno-deprecated-declarations")
fi

if ! $use_toolchain
then
  extra_configure_flags+=(
    "--macros=android_ndk:=$ANDROID_NDK"
    "--macros=android_api:=$api"
  )
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

# Avoid Deprecated POSIX Functions in ACE that OpenDDS Doesn't Use
echo '#define ACE_DISABLE_MKTEMP' >> "$ace_target/ace/config.h"
echo '#define ACE_DISABLE_TEMPNAM' >> "$ace_target/ace/config.h"
echo '#define ACE_LACKS_READDIR_R' >> "$ace_target/ace/config.h"

if $use_oci_ace_tao && [ -n "$ace_host" ]
then
  echo 'CPPFLAGS += -Wno-deprecated-declarations' >> \
    "$ace_host/include/makeinclude/platform_macros.GNU"
fi

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
