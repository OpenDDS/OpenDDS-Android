# TODO: Support SDK that comes with Android Studio
set -e

source setenv.sh

sdk_dir=android-sdk
sdk_zip=commandlinetools-linux-6858069_latest.zip

sdkmanager="./$sdk_dir/cmdline-tools/bin/sdkmanager --sdk_root=android-sdk"

if $use_java
then
  if [ ! \( -d $sdk_dir -o -L $sdk_dir \) ]
  then
    if [ -d ../$sdk_dir -o -L ../$sdk_dir ]
    then
      ln -s ../$sdk_dir
      exit 0
    elif [ -d ../../$sdk_dir -o -L ../../$sdk_dir ]
    then
      ln -s ../../$sdk_dir
      exit 0
    fi
    url=https://dl.google.com/android/repository/$sdk_zip
    echo "Downloading $url..."
    wget --no-verbose $url
    echo "Done, Unziping $sdk_zip..."
    unzip -qq $sdk_zip

    mkdir $sdk_dir
    mv cmdline-tools $sdk_dir
    rm -f $sdk_zip

    # Agree to all the licenses
    yes | $sdkmanager --licenses
  fi

  # Install target API platform
  $sdkmanager "platforms;android-$api"
fi
