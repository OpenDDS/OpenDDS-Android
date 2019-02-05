set -e

basename="xerces-c-3.2.2"
tarname="$basename.tar.gz"
url="http://apache.cs.utah.edu/xerces/c/3/sources/$tarname"
ourname="xerces_source"

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
