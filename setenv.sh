export workspace="$(cd"$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd )"
export MPC_ROOT=$workspace/MPC
export android_toolchain=${workspace}/$(cat ${workspace}/toolchain)
export PATH=$android_toolchain/bin:${PATH}
