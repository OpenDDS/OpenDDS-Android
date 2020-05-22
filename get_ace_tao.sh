set -e

source setenv.sh

if $use_oci_ace_tao
then
  name="ACE+TAO-2.2a_with_latest_patches.tar.gz"
  if [ ! -f $name ]
  then
    wget --no-verbose http://download.objectcomputing.com/TAO-2.2a/$name
  fi

  if [ ! -d $ACE_ROOT ]
  then
    tar xzf $name
  fi

  # OCI ACE/TAO 2.2a p17 to build for Android
  if ! md5sum -c "oci_ace_tao.md5" --status
  then
    patch -p1 -d ACE_wrappers < oci_ace_tao.patch
    md5sum -c "oci_ace_tao.md5"
  fi

else
  if [ ! -d MPC ]
  then
    git clone --depth 1 https://github.com/DOCGroup/MPC
  fi

  if [ ! -d ACE_TAO ]
  then
    git clone --depth 1 \
      ${ACE_TAO_REPO:-https://github.com/DOCGroup/ACE_TAO} \
      --branch ${ACE_TAO_BRANCH:-master}
  fi

fi
