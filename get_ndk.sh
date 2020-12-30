set -e

source setenv.sh

ndk_dir=android-ndk-$ndk
ndk_zip=$ndk_dir-linux-x86_64.zip

if [ ! \( -d $ndk_dir -o -L $ndk_dir \) ]
then
  if [ -d ../$ndk_dir -o -L ../$ndk_dir ]
  then
    ln -s ../$ndk_dir
    exit 0
  elif [ -d ../../$ndk_dir -o -L ../../$ndk_dir ]
  then
    ln -s ../../$ndk_dir
    exit 0
  fi
  url=https://dl.google.com/android/repository/$ndk_zip
  echo "Downloading $url..."
  wget --no-verbose $url
  echo "Done, Unziping $ndk_zip..."
  unzip -qq $ndk_zip
  echo "Done"
  rm -f $ndk_zip
fi
