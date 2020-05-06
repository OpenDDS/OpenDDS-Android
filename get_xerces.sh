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

# Get GNU libiconv
basename="libiconv-1.15"
tarname="libiconv-1.15.tar.gz"
url="https://ftp.gnu.org/pub/gnu/libiconv/$tarname"
ourname="iconv_source"
get

# Get Xerces
basename="xerces-c-3.2.2"
tarname="$basename.tar.gz"
url="https://archive.apache.org/dist/xerces/c/3/sources/$tarname"
ourname="xerces_source"
get

if ${JUST_CACHE_SOURCES:-false}
then
  exit 0
fi

# Patch Xerces To Use Our Libiconv
if ! md5sum -c "${basename}.md5" --status
then
  patch -s -p0 -d ${ourname} < ${basename}.patch
  md5sum -c "${basename}.md5"
fi
