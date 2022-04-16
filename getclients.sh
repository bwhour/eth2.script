#!/bin/bash
mkdir -p eth2clients && pushd ./eth2clients
//prysm
mkdir -p prysm && pushd ./prysm
curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh && chmod +x prysm.sh
popd

//lighthouse
wget -c https://github.com/sigp/lighthouse/releases/download/v2.2.1/lighthouse-v2.2.1-x86_64-unknown-linux-gnu.tar.gz -O - | tar -xz

