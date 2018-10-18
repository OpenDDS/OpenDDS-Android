set -e

ndk_dir=android-ndk-$ndk

if [ -z ${presetup+x} ]
then
  ndk_zip=$ndk_dir-linux-x86_64.zip

  if [ ! -d $ndk_dir ]
  then
    wget https://dl.google.com/android/repository/$ndk_zip
    unzip -qq $ndk_zip
    rm -f $ndk_zip
  fi
elif [ ! -d $presetup/$ndk_dir ]
then
  echo "ndk ($ndk_dir) is not in presetup ($presetup)"
  exit 1
fi
