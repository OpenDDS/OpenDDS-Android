set -e

source setenv.sh
source make.sh

# OpenDDS
pushd $workspace/OpenDDS > /dev/null
if [ -z "$host_tools" ]
then
  pushd build/host > /dev/null
  $make TAO_IDL_EXE opendds_idl
  popd > /dev/null
  cd build/target
fi
$make \
	DDS_Messenger_Idl \
	DDS_Messenger_Publisher \
	DDS_Messenger_Subscriber
popd > /dev/null

# ACE Tests
if $build_ace_tests
then
  pushd $ace_target/tests > /dev/null
  old_ace_root="$ACE_ROOT"
  export ACE_ROOT="$ace_target"
  $make
  export ACE_ROOT="$old_ace_root"
  unset old_ace_root
  popd > /dev/null
fi
