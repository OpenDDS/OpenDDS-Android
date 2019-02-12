set -e
source setenv.sh

name=package
rm -fr $name
mkdir $name
native_lib="lib/$abi"
java_lib="jar"

target_dds="${workspace}/OpenDDS/build/target"
target_ace_tao="${workspace}/ACE_TAO/ACE/build/target"
ace_lib="$target_ace_tao/lib"
dds_lib="$target_dds/lib"
messenger="$target_dds/java/tests/messenger/messenger_idl"

include_libs=(
  "libOpenDDS_Dcps.so"
  "libOpenDDS_Multicast.so"
  "libOpenDDS_QOS_XML_XSC_Handler.so"
  "libOpenDDS_Rtps.so"
  "libOpenDDS_Rtps_Udp.so"
  "libOpenDDS_Security.so"
  "libOpenDDS_Shmem.so"
  "libOpenDDS_Tcp.so"
  "libOpenDDS_Udp.so"

  "libidl2jni_runtime.so"
  "libtao_java.so"

  "libmessenger_idl_test.so"
)

search_locations=(
  "$dds_lib"
  "$ace_lib"
  "iconv_build/lib"
  "openssl_build/lib"
  "xerces_build/lib"
  "$android_toolchain/sysroot/usr/lib/$target"
  "$messenger"
)

for file in "${include_libs[@]}"
do
  search_locations+=($(dirname $file))
done

ignore_libraries=(
  libm.so
  libdl.so
  libc.so
  linux-gate.so.1
  libpthread.so.0
  libc.so.6
  libdl.so.2
  /lib/ld-linux.so.2
  liblog.so
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
    if [ \( -f $path/$lib \) -o \( -L $path/$lib \) ]
    then
      echo $path/$lib
      return 0
    fi
  done
  echo "Couldn't find $lib" 1>&2
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
  local path=$(readlink -f $1)
  local readelf=${target}-readelf
  for lib in $(${target}-readelf --dynamic $path 2>/dev/null | sed -n 's/.*Shared library: \[\(.*\)\]/\1/p')
  do
    if [ ! -z "$lib" -a "$lib" != $(basename $1) ]
    then
      if ! contains "$lib" "${ignore_libraries[@]}"
      then
        deps+=($lib)
      fi
    fi
  done
  echo "${deps[@]}"
}

include $java_lib $dds_lib/i2jrt.jar
include $java_lib $dds_lib/i2jrt_compact.jar
include $java_lib $dds_lib/tao_java.jar
include $java_lib $dds_lib/OpenDDS_DCPS.jar
include $java_lib $messenger/messenger_idl_test.jar

for i in "${include_libs[@]}"
do
  path="$(findfile $i ${search_locations[@]})"
  include $native_lib $path
  for lib in $(get_deps $path)
  do
    if [ ! -f "$name/$native_lib/$lib" ]
    then
      include $native_lib "$(findfile $lib ${search_locations[@]})"
    fi
  done
done

for i in $(ls $name/$native_lib)
do
  chmod +x $name/$native_lib/$i
done
