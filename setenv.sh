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
  echo "Invalid Arch: $arch, must be arm, arm64, x86, or x86_64" 1>&2
  exit 1
fi

# Set Rest of Enviroment
export TRAVIS=${TRAVIS:-false}
# if $TRAVIS
# then
#   export host_tools=$workspace/host_tools/ubuntu_18.04_x86_64
# fi
export DDS_ROOT=$workspace/OpenDDS
export toolchain_name=$ndk-$arch-android-$api-toolchain
export android_toolchain=${workspace}/${toolchain_name}
export ANDROID_NDK=$workspace/android-ndk-$ndk
export use_oci_ace_tao=${use_oci_ace_tao-"false"}
if $use_oci_ace_tao
then
  mpc_dir="ACE_wrappers/MPC"
  ace_dir="ACE_wrappers"
  tao_dir="ACE_wrappers/TAO"
else
  mpc_dir="MPC"
  ace_dir="ACE_TAO/ACE"
  tao_dir="ACE_TAO/TAO"
fi
export MPC_ROOT="${MPC_ROOT-"$workspace/${mpc_dir}"}"
export ACE_ROOT="${workspace}/${ace_dir}"
export TAO_ROOT="${workspace}/${tao_dir}"
if [ -z "$host_tools" ]
then
  ace_target="$ACE_ROOT/build/target"
  ace_host="$ACE_ROOT/build/host"
else
  export HOST_DDS="$host_tools"
  export HOST_ACE="$host_tools/ACE_TAO/ACE"
  ace_target="$ACE_ROOT"
fi
export ace_target
export PATH=${PATH}:$android_toolchain/bin:$ACE_ROOT/bin
export GNU_ICONV_ROOT=${workspace}/secdeps_prefix
export XERCESCROOT=${workspace}/secdeps_prefix
export SSL_ROOT=${workspace}/secdeps_prefix

# Optional Features
export use_java=${use_java:-false}
export use_security=${use_security:-false}
export build_ace_tests=${build_ace_tests:-true}
export host_tools=${host_tools:-}
