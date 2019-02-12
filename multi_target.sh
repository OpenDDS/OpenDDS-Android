set -e

if [ ! -f settings.sh ]
then
  echo "settings.sh needs to exist"
  exit 1
fi
source settings.sh

mkdir -p targets
export arch=NONE
export JUST_CACHE_SOURCES=true

bash get_ndk.sh
bash get_openssl.sh
bash get_xerces.sh

unset arch
unset JUST_CACHE_SOURCES 

for arch in $arches
do
  export arch
  echo $arch
  if [ ! -d targets/$arch ]
  then
    git worktree add targets/$arch HEAD
  fi
  pushd targets/$arch

  bash get_ndk.sh
  bash get_openssl.sh
  bash get_xerces.sh
  bash mk_toolchain.sh

  popd
done
