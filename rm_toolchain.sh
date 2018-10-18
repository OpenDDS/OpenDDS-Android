set -e

if [ -f toolchain ]
then
  rm -fr $(cat toolchain)
  rm toolchain
fi
