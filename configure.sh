set -e
source setenv.sh

extra_configure_flags=""

if $use_java
then
  extra_configure_flags="$extra_configure_flags --java=${workspace}/jdk"
fi

if $use_security
then
  extra_configure_flags="$extra_configure_flags --xerces3=${workspace}/xerces_build --openssl=${workspace}/openssl_build --security"
fi

cd OpenDDS
./configure --no-tests --target=android \
  --ace=${workspace}/ACE_TAO/ACE \
  --tao=${workspace}/ACE_TAO/TAO \
  --macros=CPPFLAGS+=-Wno-deprecated \
  $extra_configure_flags \


pm=../ACE_TAO/ACE/build/target/include/makeinclude/platform_macros.GNU
function prepend_pm {
  printf '%s\n%s' "$@" "$(cat $pm)" > $pm
}

prepend_pm 'CPPFLAGS+=-Wno-deprecated-declarations'
major_rev=$(echo $ndk | grep -oE '[0-9]+')
minor_rev=$(echo $ndk | grep -oE '[a-j]' | tr '[a-j]' '[0-9]')
if [ $major_rev -lt 16 ]
then
  prepend_pm "__NDK_MINOR__ := $minor_rev"
  prepend_pm "__NDK_MAJOR__ := $major_rev"
fi
prepend_pm "ANDROID_ABI:=$abi"

