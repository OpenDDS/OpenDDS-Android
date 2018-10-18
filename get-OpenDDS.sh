set -e

if [ ! -d OpenDDS ]
then
  git clone https://github.com/iguessthislldo/OpenDDS
  cd OpenDDS
  git checkout igtd/android
fi
