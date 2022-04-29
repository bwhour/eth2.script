#!/bin/bash

KEYS_DIR='/home/amber/.eth2/validator_keys'
WALLET_DIR='/home/amber/.eth2/wallets'
while getopts ":p:h" optname
do
    case "$optname" in
      "k") KEYS_DIR=$OPTARG ;;
      "w") WALLET_DIR=$OPTARG ;;
      "h") echo "prysm_import_keys.sh -k <keys dir> -w <wallets dir>" ;;
      ":") echo "No argument value for option $OPTARG" ;;
      "?") echo "Unknown option $OPTARG" ;;
      *) echo "Unknown error while processing options" ;;
    esac
    # echo "option index is $OPTIND"
done

/home/amber/.eth2/prysm/prysm.sh validator accounts import --mainnet --keys-dir=$KEYS_DIR --wallet-dir=$WALLET_DIR