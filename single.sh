set -e

bash mk_toolchain.sh
bash clean_target.sh
bash configure.sh
bash build.sh
bash rm_toolchain.sh
