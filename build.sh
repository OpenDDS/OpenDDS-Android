set -e

source setenv.sh

# Try to craft the optimal make command
make_command="make"
core_count="$(grep -c ^processor /proc/cpuinfo)"
if [ $? -ne 0 ]
then
  core_count=4
fi
make="$make_command -j $core_count"
if expr "$($make_command --version | grep -Eo '[0-9]+\.[0-9]+' | head -n 1)" '>=' 4 > /dev/null
then
  make="$make --output-sync"
fi

# OpenDDS
pushd $workspace/OpenDDS
$make
popd

# ACE Tests
if $build_ace_tests
then
  pushd $ACE_ROOT/tests
  $make
  popd
fi
