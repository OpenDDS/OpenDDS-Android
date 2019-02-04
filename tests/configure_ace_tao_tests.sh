set -e
source setenv.sh
export ACE_ROOT=$workspace/ACE_TAO/ACE/build/target 
export TAO_ROOT=$workspace/ACE_TAO/TAO/build/target 
export PATH=$ACE_ROOT/bin:${PATH}

cd $ACE_ROOT/tests
mwc.pl -type gnuace .

cd $TAO_ROOT/tests/Hello
mpc.pl -type gnuace Hello.mpc
