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

# Convert arch to target
if [ "$arch" = "arm" ]
then
  export target=arm-linux-androideabi
elif [ "$arch" = "arm64" ]
then
  export target=aarch64-linux-android
elif [ "$arch" = "x86_64" ]
then
  export target=x86_64-linux-android
elif [ "$arch" = "x86" ]
then
  export target=i686-linux-android
else
  echo "Invalid Arch: $arch, must be arm, arm64, x86, or x86_64"
  exit 1
fi

# Set Rest of Enviroment
export workspace="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd )"
export MPC_ROOT=$workspace/MPC
export android_toolchain=${workspace}/$(cat ${workspace}/toolchain)
export PATH=$android_toolchain/bin:${PATH}
