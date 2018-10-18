set -e

ndk_dir=android-ndk-$ndk
ndk_zip=$ndk_dir-linux-x86_64.zip

if [ ! -d $ndk_dir ]
then
  if [ -d ../$ndk_dir ]
  then
    ln -s ../$ndk_dir
    exit 0
  fi
  wget https://dl.google.com/android/repository/$ndk_zip
  unzip -qq $ndk_zip
  rm -f $ndk_zip
fi
