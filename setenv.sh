# Getting Configuration
if [ -z ${ndk+x} ]
then
  if ! [ -f settings.sh ]
  then
    echo "Warning: ndk is not set and there are no settings.sh, copying default.settings.sh"
    cp default.settings.sh settings.sh
  fi
  source settings.sh
fi

# Convert arch to target and abi
if [ "$arch" = "arm" ]
then
  export target=arm-linux-androideabi
  export abi="armeabi-v7a"
elif [ "$arch" = "arm64" ]
then
  export target=aarch64-linux-android
  export abi="arm64-v8a"
elif [ "$arch" = "x86_64" ]
then
  export target=x86_64-linux-android
  export abi="x86_64"
elif [ "$arch" = "x86" ]
then
  export target=i686-linux-android
  export abi="x86"
else
  echo "Invalid Arch: $arch, must be arm, arm64, x86, or x86_64"
  exit 1
fi

# Set Rest of Enviroment
export workspace="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd )"
export MPC_ROOT=$workspace/MPC
export android_toolchain=${workspace}/$(cat ${workspace}/toolchain)
export ANDROID_NDK=$workspace/android-ndk-$ndk
export PATH=$android_toolchain/bin:${PATH}
export ACE_ROOT=${workspace}/ACE_TAO/ACE
export TAO_ROOT=${workspace}/ACE_TAO/TAO

# Optional Features
export use_java=${use_java:-false}
export use_security=${use_security:-false}
export build_ace_tests=${build_ace_tests:-true}
