#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

echo build_python2.sh =========================================================

source setenv.sh
source make.sh

cd python2_source
./configure
$make
