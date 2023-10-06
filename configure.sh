#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

echo configure.sh =============================================================

source setenv.sh

extra_configure_flags=()

if $use_java
then
  if [ -z "${jdk+x}" ]
  then
    extra_configure_flags+=("--java")
  else
    extra_configure_flags+=("--java=${jdk}")
  fi
  extra_configure_flags+=("--macros=ANDROID_API_PATH=$ANDROID_SDK/platforms/android-$target_api")
fi

if $use_security
then
  extra_configure_flags+=("--xerces3=${XERCESCROOT}" "--openssl=${SSL_ROOT}" --security)
fi

if [ -n "$host_tools" ]
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

if ! $use_toolchain
then
  extra_configure_flags+=(
    "--macros=android_ndk:=$OPENDDS_ANDROID_NDK"
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
  --mpcopts "-workers $logical_cores" \
  --macros=ANDROID_ABI:=$abi \
  "${extra_configure_flags[@]}"
popd > /dev/null

# Avoid Deprecated POSIX Functions in ACE that OpenDDS Doesn't Use
echo '#define ACE_DISABLE_MKTEMP' >> "$ace_target/ace/config.h"
echo '#define ACE_DISABLE_TEMPNAM' >> "$ace_target/ace/config.h"
echo '#define ACE_LACKS_READDIR_R' >> "$ace_target/ace/config.h"

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
