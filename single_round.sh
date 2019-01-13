set -e

bash mk_toolchain.sh
bash clean_source.sh
bash configure.sh
bash build.sh
bash rm_toolchain.sh
