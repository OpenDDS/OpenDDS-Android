export workspace="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd )"

# Getting Configuration
if [ -z ${ndk+x} ]
then
  if ! [ -f ${workspace}/settings.sh ]
  then
    echo "Warning: ndk is not set and there are no settings.sh, copying default.settings.sh"
    cp ${workspace}/default.settings.sh ${workspace}/settings.sh
  fi
  source ${workspace}/settings.sh
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
elif [ "$arch" = "NONE" ] # Bypass
then
  true
else
  echo "Invalid Arch: $arch, must be arm, arm64, x86, or x86_64"
  exit 1
fi

# Set Rest of Enviroment
export DDS_ROOT=$workspace/OpenDDS
export MPC_ROOT=${MPC_ROOT-$workspace/MPC}
export toolchain_name=$ndk-$arch-android-$api-toolchain
export android_toolchain=${workspace}/${toolchain_name}
export ANDROID_NDK=$workspace/android-ndk-$ndk
export ACE_ROOT=${workspace}/ACE_TAO/ACE
if [ -z "$host_tools" ]
then
  ace_target="$ACE_ROOT/build/target"
else
  export HOST_DDS="$host_tools"
  export HOST_ACE="$host_tools/ACE_TAO/ACE"
  ace_target="$ACE_ROOT"
fi
export ace_target
export TAO_ROOT=${workspace}/ACE_TAO/TAO
export PATH=${PATH}:$android_toolchain/bin:$ACE_ROOT/bin
export GNU_ICONV_ROOT=${workspace}/iconv_build
export XERCESCROOT=${workspace}/xerces_build
export SSL_ROOT=${workspace}/openssl_build
export TRAVIS=${TRAVIS:-false}

# Optional Features
export use_java=${use_java:-false}
export use_security=${use_security:-true}
export build_ace_tests=${build_ace_tests:-true}
export host_tools=${host_tools:-}
