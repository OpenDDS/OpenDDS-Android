set -e

source setenv.sh

intre='^[0-9]+$'
if [[ ! $api =~ $intre ]]
then
  echo 'for get_xerces.sh $api must be defined' 1>&2
  exit 1
fi

need_iconv=true
if [[ $api -ge 28 ]]
then
  need_iconv=false
fi

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
if $need_iconv
then
  basename="libiconv-1.16"
  tarname="$basename.tar.gz"
  url="https://ftp.gnu.org/pub/gnu/libiconv/$tarname"
  ourname="iconv_source"
  get
fi

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
if $need_iconv
then
  if ! md5sum -c "${basename}.md5" --status
  then
    patch -s -p0 -d ${ourname} < ${basename}.patch
    md5sum -c "${basename}.md5"
  fi
fi
