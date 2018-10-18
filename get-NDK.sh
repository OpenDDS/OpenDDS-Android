set -e

ndk_dir=android-ndk-$ndk
ndk_zip=$ndk_dir-linux-x86_64.zip
toolchain_name=$ndk-$arch-android-$api-toolchain
echo $toolchain_name > toolchain

wget https://dl.google.com/android/repository/$ndk_zip
unzip $ndk_zip

./$ndk_dir/build/tools/make_standalone_toolchain.py --arch $arch --api $api --install-dir $toolchain_name

major_rev=$(echo $ndk | grep -oE '[0-9]+')
minor_rev=$(echo $ndk | grep -oE '[a-j]' | tr '[a-j]' '[0-9]')
if [ $major_rev -lt 16 ]
then
  pm=ACE_TAO/ACE/build/target/include/makeinclude/platform_macros.GNU
  printf '%s\n%s\n%s\n' "__NDK_MAJOR__ = $major_rev" "__NDK_MINOR__ = $minor_rev" "$(cat $pm)" > $pm
fi
