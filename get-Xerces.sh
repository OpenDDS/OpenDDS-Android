set -e

basename="xerces-c-3.2.2"
tarname="$basename.tar.gz"
url="http://apache.cs.utah.edu/xerces/c/3/sources/$tarname"
ourname="xerces_source"
patch_basename="${basename}_configure.ac"

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

  if ! md5sum -c "${patch_basename}.md5" --status
  then
    patch "xerces_source/configure.ac" "${patch_basename}.patch"
    md5sum -c "${patch_basename}.md5" --status
    cd "$ourname"
    autoconf
  fi

  rm -f "$tarname"
fi
