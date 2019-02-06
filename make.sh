# Try to craft the optimal make command and export it as $make
set -e

make_command="make"

# Use Number of Cores For Job Count, Default to 4
core_count="$(grep -c ^processor /proc/cpuinfo)"
if [ $? -ne 0 ]
then
  core_count=4
fi
make="$make_command -j $core_count"

# If not on Travis and Make version is at least 4, sync job output
function make_version {
  $make_command --version | grep -Eo '[0-9]+\.[0-9]+' | head -n 1
}
function make_version_cmp {
  expr $(make_version) "$1" "$2" > /dev/null
  return $?
}
if ! ${TRAVIS:-false}
then
  if make_version_cmp '>=' 4
  then
    make="$make --output-sync"
  fi
fi

export make
