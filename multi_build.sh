#!/bin/bash

# Modified Version of Script Written by Timothy Simpson

# Combinations to Test:
# Not Inlined, Speed Optimized
# Not Inlined, Size Optimized
# Inlined, Speed Optimized
# Not Inlined, Speed Optimized, Java
# Not Inlined, Size Optimized, Java
# Inlined, Speed Optimized, Java
# Not Inlined, Speed Optimized, Security
# Not Inlined, Size Optimized, Security
# Inlined, Speed Optimized, Security
# Not Inlined, Speed Optimized, Slim (Minimum Profile, No BITs)
# Not Inlined, Size Optimized, Slim
# Inlined, Speed Optimized, Slim

source setenv.sh
bash mk_toolchain.sh

common_configure_options="--target=android --mpc=$MPC_ROOT --ace=${workspace}/ACE_TAO/ACE --tao=${workspace}/ACE_TAO/TAO --macros=CPPFLAGS+=-Wno-deprecated --no-debug --macros=CPPFLAGS+=-Wno-deprecated-declarations --macros=ANDROID_ABI:=$abi"
security="--security --xerces3=${workspace}/xerces_build --openssl=${workspace}/openssl_build"
java="--java=${workspace}/jdk"
slim="--no-built-in-topics --no-content-subscription --no-ownership-profile --no-object-model-profile --no-persistence-profile"

feature_options=(" " "$slim" "$security" "$java")
flag_options=("--no-inline --optimize" "--no-inline --macros=CCFLAGS+=-Os" "--optimize")

target_dds="${workspace}/OpenDDS/build/target"
cpp_build_target="DDS_Messenger_Publisher"
java_build_target="java_both_test"
ace_lib_files="${workspace}/ACE_TAO/ACE/build/target/lib/*"
dds_lib_files="${workspace}/OpenDDS/build/target/lib/*"
cpp_output_files="${workspace}/OpenDDS/build/target/tests/DCPS/Messenger/publisher"
java_output_files="${workspace}/OpenDDS/build/target/java/tests/messenger/both/classes/Both.class"

count=0

report_dir=${workspace}/reports
mkdir -p ${report_dir}

function configure_build_round {
  bash ${workspace}/clean_target.sh
  cd OpenDDS
  ./configure ${configure_options}
  cd build/target
  make -j 8 $bt
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

    bt="${cpp_build_target}"
    lf="${ace_lib_files} ${dds_lib_files}"
    of="${cpp_output_files} ${java_output_files}"

    echo $round_options > ${report_file}
    echo "---" >> ${report_file}

    if [[ $features == *"--security"* ]]; then
      bt="$bt OpenDDS_Security"
    fi

    if [[ $features == *"--java"* ]]; then
      bt="$bt $java_build_target"
    fi

    configure_build_round

    if [ $? -eq 0 ]; then
      ldd ${cpp_output_files} >> ${report_file}
      echo "---" >> ${report_file}
      # note, this will return empty for static libraries, but ideally it would return zero
      # grab dependencies | limit to non-system libs (assumes lib directories not in path / no environment set) | parse out file name | find library file |
      # get directory entry | make listing uniform | parse out size | combine into a single line with spaces | add +'s to line | feed into bc for sum
      ldd ${cpp_output_files} | grep "not found" | cut -d ' ' -f 1 | xargs -I {} find . -name {} -type f | xargs -I {} ls -la {} | sed 's/ [ ]*/ /g' | cut -d ' ' -f 5 | xargs echo | sed 's/ / + /g' | bc >> ${report_file}
      echo "---" >> ${report_file}
      ls -latRL ${lf} ${of} >> ${report_file}
      echo "---" >> ${report_file}
      ls -1 ${lf} ${of} | xargs -I {} sh -c 'ls -laL {}; echo "---"; objdump -h {}; echo "---"' >> ${report_file}
    else
      echo "Build error!" >> ${report_file}
      echo "Build error!"
      exit 1
    fi
  done
done

