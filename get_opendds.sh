set -e

echo get_opendds.sh ===========================================================

source setenv.sh

if [ ! -d OpenDDS ]
then
  git clone --recursive --depth 1 \
    ${OPENDDS_REPO:-https://github.com/objectcomputing/OpenDDS} \
    --branch ${OPENDDS_BRANCH:-master}
fi
