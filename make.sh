set -e

# Try to craft the optimal make command
make_command="make"
core_count="$(grep -c ^processor /proc/cpuinfo)"
if [ $? -ne 0 ]
then
  core_count=4
fi
make="$make_command -j $core_count"
function make_version {
  $make_command --version | grep -Eo '[0-9]+\.[0-9]+' | head -n 1
}
function make_version_cmp {
  expr $(make_version) "$1" "$2" > /dev/null
  return $?
}
if make_version_cmp '>=' 4
then
  make="$make --output-sync"
fi
export make
