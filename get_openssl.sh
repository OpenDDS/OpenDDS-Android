set -e

basename="openssl-1.1.1a"
tarname="$basename.tar.gz"
url="https://www.openssl.org/source/$tarname"
ourname="openssl_source"

if [ ! -d "$ourname" ]
then
  if [ -d "../$basename" ]
  then
    ln -s "../$basename" "$ourname"
  else
    curl -OJL "$url"
    tar -xzf "$tarname"
    mv "$basename" "$ourname"
  fi

  rm -f "$tarname"
fi
