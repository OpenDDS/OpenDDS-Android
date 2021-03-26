# TODO: Support SDK that comes with Android Studio
set -e

echo get_sdk.sh ===============================================================

source setenv.sh

case $host_os in
  'linux')
    sdk_platform_name="linux"
    ;;

  'macos')
    sdk_platform_name="mac"
    ;;

  *)
    echo "Unknown host_os: \"$host_os\"" 1>&2
    exit 1
    ;;
esac

sdk_dir=android-sdk
# TODO: Support Different SDK Versions?
sdk_zip=commandlinetools-$sdk_platform_name-6858069_latest.zip

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
  $sdkmanager "platforms;android-$target_api"
fi
