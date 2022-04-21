#!/bin/bash
# -n Server Number

SERVER_NUMBER=0
SU_PASSWORD='&kHLJ2h#zQ&BSIuH'

while getopts ":n:a:h" optname
do
    case "$optname" in
      "n") SERVER_NUMBER=$OPTARG ;;
      "a") SU_PASSWORD=$OPTARG ;;
      "h") echo "setup_systemd.sh -n 1-a <password>" ;;
      ":") echo "No argument value for option $OPTARG" ;;
      "?") echo "Unknown option $OPTARG" ;;
      *) echo "Unknown error while processing options" ;;
    esac
    # echo "option index is $OPTIND"
done

# prysm beacon
echo '[Unit]
Description=Prysm Beacon chain daemon
After=network.target

[Service]
ExecStart=/home/amber/.eth2/eth2clients/prysm/prysm.sh beacon-chain \
  --prater \
  --datadir=/node/first \
  --http-web3provider="https://blockchain-beta.amberainsider.com/goerli,https://apis.ankr.com/71f4b42d70a54565894113da390ec08b/c942b301ab4cd3e91c05afbc7c0ab06f/eth/fast/goerli,https://rpc.goerli.mudit.blog" \
  -genesis-state=/home/amber/.eth2/genesis.ssz \
  --p2p-max-peers=500 \
  --block-batch-limit=512 \
  --accept-terms-of-use
SyslogIdentifier=prysmbn
StartLimitInterval=0
LimitNOFILE=65536
LimitNPROC=65536
KillMode=process
KillSignal=SIGINT
TimeoutStopSec=90
RestartSec=5s
StandardOutput=syslog
StandardError=syslog
Restart=always
User=amber

[Install]
WantedBy=multi-user.target' > ~/prysmbn.service
echo $SU_PASSWORD | sudo -S cp ~/prysmbn.service  /etc/systemd/system/prysmbn.service
rm ~/prysmbn.service

# prysm validator
echo '[Unit]
Description=Prysm Validator daemon
After=network.target
Wants=prysmbn.service

[Service]
ExecStart=/home/amber/.eth2/eth2clients/prysm/prysm.sh validator \
  --prater \
  --wallet-dir=/home/amber/.eth2/prysmvc \
  --wallet-password-file= /home/amber/.eth2/prysmvc/passwds \
  --graffiti Amber
Restart=always
User=amber
SyslogIdentifier=prysmvc
StartLimitInterval=0
LimitNOFILE=65536
LimitNPROC=65536

[Install]
WantedBy=multi-user.target' > ~/prysmvc.service
echo $SU_PASSWORD | sudo -S cp ~/prysmvc.service /etc/systemd/system/prysmvc.service
rm ~/prysmvc.service

# rsyslog.d
echo 'if $programname == "prysmbn" then /home/amber/logs/prysmbn/prysmbn.log
if $programname == "prysmvc" then /home/amber/logs/prysmvc/prysmvc.log
& stop' > ~/prysm.conf
echo $SU_PASSWORD | sudo -S cp ~/prysm.conf /etc/rsyslog.d/prysm.conf
rm ~/prysm.conf

# logrotate
touch /home/amber/logs/prysmbn/prysmbn.log
touch /home/amber/logs/prysmvc/prysmvc.log

# start service
echo $SU_PASSWORD | sudo -S chmod 755 /etc/systemd/system/prysmbn.service
echo $SU_PASSWORD | sudo -S systemctl enable prysmbn.service
echo $SU_PASSWORD | sudo -S systemctl daemon-reload
echo $SU_PASSWORD | sudo -S service prysmbn start

echo $SU_PASSWORD | sudo -S chmod 755 /etc/systemd/system/prysmvc.service
echo $SU_PASSWORD | sudo -S systemctl enable prysmvc.service
echo $SU_PASSWORD | sudo -S systemctl daemon-reload
echo $SU_PASSWORD | sudo -S service prysmvc start