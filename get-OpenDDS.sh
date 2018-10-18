set -e

if [ -z ${presetup+x} ]
then
  git clone https://github.com/iguessthislldo/OpenDDS
  cd OpenDDS
  git checkout igtd/android
elif [ ! -d $presetup/OpenDDS ]
then
  echo "OpenDDS is not in presetup ($presetup)"
  exit 1
fi
