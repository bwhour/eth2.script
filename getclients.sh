#!/bin/bash
mkdir eth2clients && cd eth2clients
//prysm
mkdir prysm && cd prysm
curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh && chmod +x prysm.sh

//lighthouse
curl -C -o lighthouse.tar.gz https://github.com/sigp/lighthouse/releases/download/v2.2.1/lighthouse-v2.2.1-x86_64-unknown-linux-gnu.tar.gz 
tar -zxvf lighthouse.tar.gz
