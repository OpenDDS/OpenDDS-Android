set -e

echo "Copying Files.."
rm -fr messenger messenger.tar.gz
mkdir messenger

function include {
  dest=messenger/$1
  mkdir -p $dest
  shift
  for file in $@
  do
    cp -Lr $file $dest
  done
}

include lib \
  $(find ACE_TAO/ACE/build/target/lib -name '*.so') \
  $(find OpenDDS/build/target/lib -name '*.so') \

include bin \
  OpenDDS/build/target/bin/DCPSInfoRepo \
  OpenDDS/build/target/bin/repoctl \
  ACE_TAO/ACE/bin/PerlACE \
  OpenDDS/bin/PerlDDS \

include test \
  OpenDDS/build/target/DevGuideExamples/DCPS/Messenger/subscriber \
  OpenDDS/build/target/DevGuideExamples/DCPS/Messenger/publisher \
  run_test.pl \
  rtps_disc.ini \

cat << EOT > messenger/run_test.sh
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$(pwd)/lib
export PATH=\$PATH:\$(pwd)/bin
export ACE_ROOT=\$(pwd)
export DDS_ROOT=\$(pwd)
cd test
perl run_test.pl
EOT

echo "Creating Archive..."

tar -h --create --gzip --file 'messenger.tar.gz' messenger
rm -fr messenger

echo "Done!"
