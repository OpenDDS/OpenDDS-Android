set -e
source setenv.sh
export ACE_ROOT=$workspace/ACE_TAO/ACE/build/target 
export HOST_ACE=$workspace/ACE_TAO/ACE/build/host
export TAO_ROOT=$workspace/ACE_TAO/TAO/build/target 
export PATH=$ACE_ROOT/bin:${PATH}

# cd $ACE_ROOT/tests
# make -j 8

cd $TAO_ROOT/tests/Hello
make -j 8
