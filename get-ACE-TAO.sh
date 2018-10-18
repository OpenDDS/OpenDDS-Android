set -e

if [ -z ${presetup+x} ]
then
  git clone https://github.com/DOCGroup/MPC

  git clone https://github.com/iguessthislldo/ACE_TAO.git
  cd ACE_TAO
  git checkout igtd/android
elif [ ! -d $presetup/MPC]
then
  echo "MPC is not in presetup ($presetup)"
  exit 1
elif [ ! -d $presetup/ACE_TAO ]
then
  echo "ACE_TAO is not in presetup ($presetup)"
  exit 1
fi
