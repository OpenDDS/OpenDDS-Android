#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

echo get_openssl.sh ===========================================================

source setenv.sh

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
        download_file "$url"
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

# TODO: OpenDDS can't compile with OpenSSL 3 right now
# if [ $ndk_major_rev -lt 22 ]
# then
#   version="1.1.1k"
# else
#   version="3.0.0-alpha13"
# fi
version="1.1.1l"
basename="openssl-$version"
tarname="$basename.tar.gz"
url="https://www.openssl.org/source/$tarname"
ourname="openssl_source"
get
