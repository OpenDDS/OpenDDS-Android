set -e

source setenv.sh

if [ ! -d $toolchain_name ]
then
  $ANDROID_NDK/build/tools/make_standalone_toolchain.py \
    --arch $arch --api $api --install-dir $toolchain_name
fi
