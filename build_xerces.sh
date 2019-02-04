set -e

mkdir -p xerces_build
dest=$(pwd)/xerces_build

source setenv.sh
source make.sh

cd xerces_source

./configure \
  --prefix=$dest \
  --host=$target \
  --enable-transcoder-gnuiconv \
  CC=${target}-${CC:-clang} \
  CXX=${target}-${CC:-clang++} \
  LD=${target}-${LD:-ld} \
  CFLAGS="-fPIE -fPIC" \
  LDFLAGS="-pie" \

$make
make install
