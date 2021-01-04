set -e

source setenv.sh

if $need_toolchain && [ ! -d $toolchain_name ]
then
  echo "Generating Standalone Toolchain"
  $ANDROID_NDK/build/tools/make_standalone_toolchain.py \
    --arch $arch --api $api --install-dir $toolchain_name
  echo "Done"
fi
