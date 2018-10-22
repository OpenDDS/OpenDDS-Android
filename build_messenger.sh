source setenv.sh

cd OpenDDS/build/target
source setenv.sh
cd DevGuideExamples/DCPS/Messenger
mwc.pl -type gnuace . && make -j 8
