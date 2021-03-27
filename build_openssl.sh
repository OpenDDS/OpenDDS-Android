#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

echo build_openssl.sh =========================================================

source setenv.sh
source make.sh

path=$ANDROID_NDK/toolchains/llvm/prebuilt/$ndk_platform_name/bin
if [ ! -d $path ]
then
  echo "$path does not exist!"
  exit 1
fi
export PATH=$path:$PATH

cd openssl_source
./Configure no-tests no-shared android-$arch -D__ANDROID_API__=$api --prefix=$SSL_ROOT
$make_command install_sw # No documentation, see https://github.com/openssl/openssl/issues/8170
# It seems OpenSSL (or at least OpenSSL 1.1.1) doesn't seem to support parallel builds
# TODO: Fix this or pick a new version of OpenSSL to use that does. Probably
# OpenSSL 3 with my configure patch when it comes out.
