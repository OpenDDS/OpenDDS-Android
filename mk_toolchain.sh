set -e

ndk_dir=android-ndk-$ndk
toolchain_name=$ndk-$arch-android-$api-toolchain
major_rev=$(echo $ndk | grep -oE '[0-9]+')
if [ ! -d $toolchain_name ]
then
  echo $toolchain_name > toolchain
  ./$ndk_dir/build/tools/make_standalone_toolchain.py --arch $arch --api $api --install-dir $toolchain_name $extra_flags
fi
