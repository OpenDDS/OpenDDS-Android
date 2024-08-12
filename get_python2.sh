#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

echo get_python2.sh ===========================================================

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

version="2.7.18"
basename="Python-$version"
tarname="$basename.tgz"
url="https://www.python.org/ftp/python/$version/$tarname"
ourname="python2_source"
get
