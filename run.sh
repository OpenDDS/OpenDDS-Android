set -ex
source settings.sh

bash get_ndk.sh
bash get_toolchain.sh
bash get_ace_tao.sh
bash get_opendds.sh
if ${use_security:-false}; then bash get_xerces.sh; fi
if ${use_security:-false}; then bash get_openssl.sh; fi

bash configure.sh
bash build.sh
