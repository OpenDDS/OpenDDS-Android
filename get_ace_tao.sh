set -e

source setenv.sh

if [ ! -d MPC ]
then
  git clone --depth 1 https://github.com/DOCGroup/MPC
fi

if [ ! -d ACE_TAO ]
then
  git clone --depth 1 ${ACE_TAO_REPO:-https://github.com/DOCGroup/ACE_TAO} --branch ${ACE_TAO_BRANCH:-master}
fi
