#!/bin/bash
echo $SU_PASSWORD | sudo -S yum -y update
echo $SU_PASSWORD | sudo -S yum groupinstall "Development Tools"
echo $SU_PASSWORD | sudo -S yum -y install openssl-devel libffi-devel bzip2-devel wget
echo $SU_PASSWORD | sudo -S yum -y install git go gcc llvm clang
