set -e

source setenv.sh
cd OpenDDS
./configure --no-tests --target=android \
  --ace=${workspace}/ACE_TAO/ACE \
  --tao=${workspace}/ACE_TAO/TAO \
  --marcos=CXFLAGS+=-Wdeprecated-declarations

pm=../ACE_TAO/ACE/build/target/include/makeinclude/platform_macros.GNU
function prepend_pm {
  printf '%s\n%s' "$@" "$(cat $pm)" > $pm
}

major_rev=$(echo $ndk | grep -oE '[0-9]+')
minor_rev=$(echo $ndk | grep -oE '[a-j]' | tr '[a-j]' '[0-9]')
if [ $major_rev -lt 16 ]
then
  prepend_pm "__NDK_MINOR__ := $minor_rev"
  prepend_pm "__NDK_MAJOR__ := $major_rev"
fi

