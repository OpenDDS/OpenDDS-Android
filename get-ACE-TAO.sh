set -e

if [ ! -d MPC ]
then
  git clone --depth 1 https://github.com/DOCGroup/MPC
fi

if [ ! -d ACE_TAO ]
then
  git clone --depth 1 https://github.com/DOCGroup/ACE_TAO
fi
