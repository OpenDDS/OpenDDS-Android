set -e

ndk_dir=android-ndk-$ndk
ndk_zip=$ndk_dir-linux-x86_64.zip
toolchain_name=$ndk-$arch-android-$api-toolchain
echo $toolchain_name > toolchain

wget https://dl.google.com/android/repository/$ndk_zip
unzip -qq $ndk_zip

./$ndk_dir/build/tools/make_standalone_toolchain.py --arch $arch --api $api --install-dir $toolchain_name
