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

# Get GNU libiconv
basename="libiconv-1.15"
tarname="libiconv-1.15.tar.gz"
url="https://ftp.gnu.org/pub/gnu/libiconv/$tarname"
ourname="iconv_source"
get

# Get Xerces
basename="xerces-c-3.2.2"
tarname="$basename.tar.gz"
url="http://apache.cs.utah.edu/xerces/c/3/sources/$tarname"
ourname="xerces_source"
get

# Patch Xerces To Use Our Libiconv
if ! md5sum -c "${basename}.md5" --status
then
  patch "$ourname/src/CMakeLists.txt" "${basename}_src_CMakeLists.txt.patch"
  patch "$ourname/cmake/XercesTranscoderSelection.cmake" "${basename}_cmake_XercesTranscoderSelection.cmake.patch"
  patch "$ourname/src/xercesc/util/Transcoders/IconvGNU/IconvGNUTransService.hpp" "${basename}_IconvGNUTransService.hpp.patch"
  patch "$ourname/CMakeLists.txt" "${basename}_CMakeLists.txt.patch"
  md5sum -c "${basename}.md5"
fi
