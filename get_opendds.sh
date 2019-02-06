set -e

if [ ! -d OpenDDS ]
then
  git clone --recursive --depth 1 https://github.com/objectcomputing/OpenDDS
fi
