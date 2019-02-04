set -e
source setenv.sh

name=ace_tests
echo "Copying Files into $name..."
rm -fr $name $name.tar.gz
mkdir $name

target_dds="${workspace}/OpenDDS/build/target"
target_ace_tao="${workspace}/ACE_TAO/ACE/build/target"
ace_lib="$target_ace_tao/lib"
dds_lib="$target_dds/lib"

test_bins=(
  ACE_TAO/ACE/build/target/tests/ACE_Test
  ACE_TAO/TAO/build/target/tests/Hello/client
  ACE_TAO/TAO/build/target/tests/Hello/server
)

search_locations=(
  "$dds_lib"
  "$ace_lib"
)

for file in "${test_bins[@]}"
do
  search_locations+=($(dirname $file))
done

ignore_libraries=(
  libm.so
  libdl.so
  libc.so
  libc++_shared.so
)

function include {
  dest=$name/$1
  mkdir -p $dest
  shift
  for file in $@
  do
    echo "  Including $file in $dest"
    cp -Lr $file $dest
  done
}

function findfile {
  local path lib="$1"
  shift
  for path in $@
  do
    if [ -f $path/$lib ]
    then
      echo $path/$lib
      return 0
    fi
  done
  echo "Couldn't find $lib"
  return 1
}

function contains {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function get_deps {
  local deps=()
  for lib in $(ndk-depends $1 2>/dev/null)
  do
    if [ "$lib" != $(basename $1) ]
    then
      if ! contains "$lib" "${ignore_libraries[@]}"
      then
        deps+=($lib)
      fi
    fi
  done
  echo "${deps[@]}"
}

for bin in "${test_bins[@]}"
do
  include test $bin
  for lib in $(get_deps $bin)
  do
    include lib "$(findfile $lib ${search_locations[@]})"
  done
done

include bin \
  ACE_TAO/ACE/bin/PerlACE \
  OpenDDS/bin/PerlDDS \

include lib \
  $(find . -name 'libc++_shared.so') \

include test \
  ACE_TAO/TAO/build/target/tests/Hello/run_test.pl

cat << EOT > $name/setenv.sh
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$(pwd)/lib
export PATH=\$PATH:\$(pwd)/bin
export ACE_ROOT=\$(pwd)
export DDS_ROOT=\$(pwd)
EOT

cat << EOT > $name/run_test.sh
source setenv.sh
cd test
echo "Running ACE_Test"
if ! ./ACE_Test
then
echo "Failed"
fi
echo "Running TAO Hello"
if ! perl run_test.pl
then
echo "Failed"
fi
EOT

cat << EOT > $name/gdb.sh
source setenv.sh
cd test
exec gdbserver host:2000 ACE_Test
EOT

echo "Creating Archive $name.tar.gz..."

tar -h --create --gzip --file "$name.tar.gz" $name
rm -fr $name

echo "Done!"
