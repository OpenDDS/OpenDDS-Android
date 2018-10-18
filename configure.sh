source setenv.sh
cd OpenDDS
./configure --no-tests --target=android \
  --ace=${workspace}/ACE_TAO/ACE \
  --tao=${workspace}/ACE_TAO/TAO \
