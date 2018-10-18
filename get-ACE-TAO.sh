set -e

if [ ! -d MPC ]
then
  git clone https://github.com/DOCGroup/MPC
fi

if [ ! -d ACE_TAO ]
then
  git clone https://github.com/iguessthislldo/ACE_TAO.git
  cd ACE_TAO
  git checkout igtd/android
fi
