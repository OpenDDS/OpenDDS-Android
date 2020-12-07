set -e

source setenv.sh

if $use_oci_ace_tao
then
  name="ACE+TAO-2.2a_with_latest_patches.tar.gz"
  if [ ! -f $name ]
  then
    url=http://download.objectcomputing.com/TAO-2.2a/$name
    echo "Downloading $url"
    wget --no-verbose $url
  else
    echo "Already Downloaded $name"
  fi

  if [ ! -d $ACE_ROOT ]
  then
    echo "Extracting $name"
    tar xzf $name
  else
    echo "Already Extracted $name"
  fi

  # If needed, patch OCI ACE/TAO
  patch_file='oci_ace_tao.patch'
  md5_file='oci_ace_tao.md5'
  if [ -f "$patch_file" -a "$md5_file" ]
  then
    echo "Checking Patch"
    patch_check=ACE_wrappers/patched_for_android_matrix
    if ! md5sum -c "$md5_file" --status
    then
      patch -p1 -d ACE_wrappers < "$patch_file"
      md5sum -c "$md5_file"
      touch $patch_check
    elif [ ! -f $patch_check ]
    then
      echo "Patch is not needed at this time, disable it for now!" 1>&2
      exit 1
    else
      echo "Already Patched $name"
    fi
  else
    echo "No Patch File Found"
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
      --branch ${ACE_TAO_BRANCH:-$ace_tao_default_branch}
  fi

fi
