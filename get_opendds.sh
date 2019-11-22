set -e

if [ ! -d OpenDDS ]
then
  git clone --recursive --depth 1 ${OPENDDS_REPO:-https://github.com/objectcomputing/OpenDDS} --branch ${OPENDDS_BRANCH:-master}
fi

# if ${TRAVIS:-false}
# then
#   if [ ! -d host_tools ]
#   then
#     git clone --depth 1 https://github.com/iguessthislldo/OpenDDS --branch host_tools host_tools
#   fi
# fi
