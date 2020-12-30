set -e

function get {
  if [ ! -d "$ourname" ]
  then
    if [ ! \( -f $tarname -o -L $tarname \) ]
    then
      if [ -f ../$tarname -o -L ../$tarname ]
      then
        ln -s "../$tarname" "$tarname"
      elif [ -f ../../$tarname -o -L ../../$tarname ]
      then
        ln -s "../../$tarname" "$tarname"
      else
        curl -OJL "$url"
      fi
    fi

    if ! ${JUST_CACHE_SOURCES:-false}
    then
      tar -xzf "$tarname"
      mv "$basename" "$ourname"
      rm -f "$tarname"
    fi
  fi
}

basename="openssl-1.1.1i"
tarname="$basename.tar.gz"
url="https://www.openssl.org/source/$tarname"
ourname="openssl_source"
if [ "$ndk" != 'r22-beta1' ]
then
  get
else
  if [ ! -d openssl_source ]
  then
    git clone --depth 1 'https://github.com/iguessthislldo/openssl' \
      --branch 'igtd/android-ndk-r22-beta1' openssl_source
  fi
fi
