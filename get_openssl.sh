set -e

function get {
  if [ ! -d "$ourname" ]
  then
    if [ ! -f "$tarname" ]
    then
      if [ -f "../$tarname" ]
      then
        ln -s "../$tarname" "$tarname"
      else
        curl -OJL "$url"
      fi
    fi

    tar -xzf "$tarname"
    mv "$basename" "$ourname"
    rm -f "$tarname"
  fi
}

basename="openssl-1.1.1a"
tarname="$basename.tar.gz"
url="https://www.openssl.org/source/$tarname"
ourname="openssl_source"
get
