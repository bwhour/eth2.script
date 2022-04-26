#!/bin/bash
SU_PASSWORD='&kHLJ2h#zQ&BSIuH'
echo $SU_PASSWORD | sudo -S yum -y update
echo $SU_PASSWORD | sudo -S yum groupinstall "Development Tools"
echo $SU_PASSWORD | sudo -S yum -y install openssl-devel libffi-devel bzip2-devel wget jq
echo $SU_PASSWORD | sudo -S yum -y install git go gcc llvm clang

#install docker-compose
echo $SU_PASSWORD | sudo -S curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)"  -o  /usr/local/bin/docker-compose
echo $SU_PASSWORD | sudo -S chmod +x /usr/local/bin/docker-compose

