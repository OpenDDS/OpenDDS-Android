set -e

source setenv.sh

if $use_oci_ace_tao
then
  name="ACE+TAO-2.2a_with_latest_patches.tar.gz"
  wget --no-verbose http://download.objectcomputing.com/TAO-2.2a/$name
  tar xzf $name

else
  if [ ! -d MPC ]
  then
    git clone --depth 1 https://github.com/DOCGroup/MPC
  fi

  if [ ! -d ACE_TAO ]
  then
    git clone --depth 1 ${ACE_TAO_REPO:-https://github.com/DOCGroup/ACE_TAO} --branch ${ACE_TAO_BRANCH:-master}
  fi

fi
