set -e

source setenv.sh
make=make -j 8 --sync-output

# OpenDDS
pushd $DDS_ROOT
$make
popd

# ACE Tests
if $build_ace_tests
then
  pushd $ACE_ROOT/tests
  $make
  popd
fi
