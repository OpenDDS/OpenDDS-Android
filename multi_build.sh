#!/bin/bash
set -e

# Modified Version of Script Written by Timothy Simpson

source setenv.sh
bash mk_toolchain.sh

common_configure_options="--target=android --mpc=$MPC_ROOT --ace=${workspace}/ACE_TAO/ACE --tao=${workspace}/ACE_TAO/TAO --macros=CPPFLAGS+=-Wno-deprecated --no-inline --no-debug --macros=CPPFLAGS+=-Wno-deprecated-declarations --macros=ANDROID_ABI:=$abi"
security="--security --xerces3=${workspace}/xerces_build --openssl=${workspace}/openssl_build"
java="--java=${workspace}/jdk"
slim="--no-built-in-topics --no-content-subscription --no-ownership-profile --no-object-model-profile --no-persistence-profile"

feature_options=("$java" "$java $slim" "$java $security" "$java $slim $security")
flag_options=("--no-inline --optimize" "--no-inline --macros=CCFLAGS+=-Os" "--optimize")

target_dds="${workspace}/OpenDDS/build/target"
target_ace_tao="${workspace}/ACE_TAO/ACE/build/target"
ace_lib="$target_ace_tao/lib"
dds_lib="$target_dds/lib"
messenger="$target_dds/tests/DCPS/Messenger"
java_messenger="$target_dds/java/tests/messenger"
cpp_build_target="DDS_Messenger_Publisher"
java_build_target="idl2jni_compact java_both_test"

ignore_libraries=(
  libm.so
  libdl.so
  libc.so
  libc++_shared.so
  libcrypto.so
  libcrypto.so.1.1
  libssl.so
  libssl.so.1.1
  libxerces-c-3.2.so
  libxerces-c.so
)

search_locations=(
  "$dds_lib"
  "$ace_lib"
  "$messenger"
)

native_files=(
  "$messenger/publisher"
)

java_files=(
  "$java_messenger/both/classes/Both.class"
  "$dds_lib/tao_java.jar"
  "$dds_lib/i2jrt.jar"
  "$dds_lib/OpenDDS_DCPS.jar"
  "$dds_lib/i2jrt_compact.jar"
)

java_support_files=(
  "$dds_lib/libidl2jni_runtime.so"
  "$dds_lib/libOpenDDS_DCPS_Java.so"
  "$dds_lib/libtao_java.so"
)

security_support_files=(
  "$dds_lib/libOpenDDS_Security.so"
)

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
    if ! contains "$lib" "${ignore_libraries[@]}"
    then
      deps+=($lib)
    fi
  done
  echo "${deps[@]}"
}

function sizeof {
  if [ -f $1 ]
  then
    du -Lb $1 | cut -d $'\t' -f 1
  else
    echo "Error: $1 does not exist" 1>&2
    echo "-1"
  fi
}

count=0

report_dir=${workspace}/reports
mkdir -p ${report_dir}

function configure_build_round {
  bash ${workspace}/clean_target.sh
  cd OpenDDS
  ./configure ${configure_options} || exit 1
  cd build/target
  make -j 8 $targets || exit 1
}

for features in "${feature_options[@]}"
do
  for flags in "${flag_options[@]}"
  do
    cd ${workspace}

    count=$((count + 1))
    count_str=`printf "%0*d" 3 ${count}`
    report_file="${report_dir}/build_${count_str}_report.txt"

    round_options="${features} ${flags}"
    configure_options="$common_configure_options $round_options"

    targets="${cpp_build_target}"

    echo $round_options > ${report_file}

    if [[ $features == *"--security"* ]]; then
      targets="$targets OpenDDS_Security"
    fi

    if [[ $features == *"--java"* ]]; then
      targets="$targets $java_build_target"
    fi

    configure_build_round
    cd ${workspace}

    if [ $? -eq 0 ]; then
      round_native_files=("${native_files[@]}")
      file_group=()

      if [[ $features == *"--java"* ]]; then
        round_native_files+=("${java_support_files[@]}")
        file_group+=("${java_files[@]}")
      fi

      if [[ $features == *"--security"* ]]; then
        round_native_files+=("${security_support_files[@]}")
      fi

      native_group_names=()
      for file in "${round_native_files[@]}"
      do
        for dep in $(get_deps $file)
        do
          if ! contains "$dep" "${native_group_names[@]}"
          then
            native_group_names+=($dep)
          fi
        done
      done

      for file in "${native_group_names[@]}"
      do
        file_group+=($(findfile $file "${search_locations[@]}"))
      done

      total=0
      for file in "${file_group[@]}"
      do
        file_size=$(sizeof $file)
        if [ "$file_size" = "-1" ]
        then
          echo "$file is Missing!" >> ${report_file}
          exit 1
        fi
        total=$(expr $total '+' $file_size)
        printf '%s\t%s\n' $file $file_size >> ${report_file}
      done
      echo 'Total:' $total 'B' '(' $(expr $total '/' 1048576) 'MiB )' >> ${report_file}
    else
      echo "Build error!" >> ${report_file}
      echo "Build error!"
      exit 1
    fi
  done
done
