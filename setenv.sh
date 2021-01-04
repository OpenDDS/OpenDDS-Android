if ${OPENDDS_ANDROID_SETENV:-false}; then return; fi
export OPENDDS_ANDROID_SETENV='true'

export workspace="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd )"

# Getting Configuration
if [ -z ${ndk+x} ]
then
  if ! [ -f ${workspace}/settings.sh ]
  then
    echo "Warning: ndk is not set and there are no settings.sh, copying default.settings.sh" 1>&2
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

# Android NDK
ndk_major_rev=$(echo $ndk | grep -oE '[0-9]+')
ndk_minor_rev=$(echo $ndk | grep -oE '[a-j]' | tr '[a-j]' '[0-9]')
export ANDROID_NDK="${ANDROID_NDK-"$workspace/android-ndk-$ndk"}"
export use_toolchain=${use_toolchain-"false"}
need_toolchain=$use_toolchain
# Toolchain is needed for Iconv and Xerces
# TODO: See if they can be built without the toolchain
export use_security=${use_security:-false}
if $use_security
then
  need_toolchain=true
fi
export need_toolchain
if $need_toolchain
then
  export toolchain_name="$ndk-$arch-android-$api-toolchain"
  export android_toolchain="${workspace}/${toolchain_name}"
  export PATH=${PATH}:"$android_toolchain/bin"
fi

# OpenDDS
export DDS_ROOT="${DDS_ROOT-"$workspace/OpenDDS"}"

# ACE/TAO
export use_oci_ace_tao=${use_oci_ace_tao-"false"}
if $use_oci_ace_tao
then
  ace_tao='oci'
fi
export ace_tao=${ace_tao-'doc_group_master'}
case $ace_tao in
  'doc_group_master')
    export ace_tao_default_branch='master'
    ;;

  'doc_group_ace6_tao2')
    export ace_tao_default_branch='ace6tao2'
    ;;

  'oci')
    use_oci_ace_tao='true'
    ;;

  *)
    echo "Invalid ace_tao: $ace_tao" 1>&2
    exit 1
    ;;
esac
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
export MPC_ROOT="${MPC_ROOT-"${workspace}/${mpc_dir}"}"
export ACE_ROOT="${ACE_ROOT-"${workspace}/${ace_dir}"}"
export TAO_ROOT="${TAO_ROOT-"${workspace}/${tao_dir}"}"
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
export PATH=${PATH}:"$ACE_ROOT/bin"

# Optional Features
export use_java=${use_java:-false}
if $use_security
then
  export GNU_ICONV_ROOT="${GNU_ICONV_ROOT-"${workspace}/secdeps_prefix"}"
  export XERCESCROOT="${XERCESCROOT-"${workspace}/secdeps_prefix"}"
  export SSL_ROOT="${SSL_ROOT-"${workspace}/secdeps_prefix"}"
fi
export build_ace_tests=${build_ace_tests:-true}
export host_tools=${host_tools:-}
