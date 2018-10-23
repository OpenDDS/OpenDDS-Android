set -e
rm -f ACE_TAO/ACE/build/target/ace/config.h
rm -fr ACE_TAO/ACE/build/target
rm -fr ACE_TAO/TAO/build/target
rm -fr OpenDDS/build/target
rm -f \
  OpenDDS/build/host/host_tools.mwc* \
  OpenDDS/build/host/user_macros.GNU* \
  OpenDDS/build/host/setenv.sh* \
