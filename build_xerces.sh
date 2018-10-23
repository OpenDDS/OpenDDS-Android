set -e

mkdir -p xerces_build
dest=$(pwd)/xerces_build

source setenv.sh

cd xerces_source

./configure \
  --prefix=$dest \
  --host=$target \
  CC=${target}-${CC:-clang} \
  CXX=${target}-${CC:-clang++} \
  LD=${target}-${LD:-ld} \
  CFLAGS="-fPIE -fPIC" \
  LDFLAGS="-pie" \

make -j 8
make install
