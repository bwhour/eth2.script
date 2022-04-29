#!/bin/bash

KEYS-DIR='/home/amber/.eth2/validator_keys'
WALLET-DIR='/home/amber/.eth2/wallets'
while getopts ":p:h" optname
do
    case "$optname" in
      "k") KEYS-DIR=$OPTARG ;;
      "w") WALLET-DIR=$OPTARG ;;
      "h") echo "new_lighthouse_systemd.sh -k <password>" ;;
      ":") echo "No argument value for option $OPTARG" ;;
      "?") echo "Unknown option $OPTARG" ;;
      *) echo "Unknown error while processing options" ;;
    esac
    # echo "option index is $OPTIND"
done

/home/amber/.eth2/prysm/prysm.sh validator accounts import --mainnet --keys-dir=$KEYS-DIR --wallet-dir=$WALLET-DIR