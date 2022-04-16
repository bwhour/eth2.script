#!/bin/bash
# -n Server Number

SERVER_NUMBER=0
SU_PASSWORD=''

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

if [ $SERVER_NUMBER -le 0 ]; then
    echo "SERVER_NUMBER MUST BE GREATER THAN 0"
    exit 1
fi

NODE_NUMBER_1=$(expr $SERVER_NUMBER \* 2 - 1 | xargs printf "%02d")
NODE_NUMBER_2=$(expr $SERVER_NUMBER \* 2 | xargs printf "%02d")

# prysm beacon
echo '[Unit]
Description=Prysm Beacon chain daemon
After=network.target

[Service]
ExecStart=/mnt/node/prysm/prysm.sh beacon-chain --http-web3provider=https://blockchain.amberainsider.com/eth --p2p-max-peers=500 --block-batch-limit=512
SyslogIdentifier=prysmbeacon
StartLimitInterval=0
LimitNOFILE=65536
LimitNPROC=65536
 
Restart=always
User=amber

[Install]
WantedBy=multi-user.target' > ~/prysmbeacon.service
echo $SU_PASSWORD | sudo -S cp ~/prysmbeacon.service  /etc/systemd/system/prysmbeacon.service
rm ~/prysmbeacon.service

# prysm validator
echo '[Unit]
Description=Prysm Validator daemon
After=network.target
Wants=prysm-beacon.service

[Service]
ExecStart=/mnt/node/prysm/prysm.sh validator --wallet-dir /home/amber/eth2/validator_keys --wallet-password-file DIR/TO/YOUR_PASSWORDFILE --graffiti YOUR_GRAFFITI
Restart=always
User=amber
SyslogIdentifier=prysmvalidator
StartLimitInterval=0
LimitNOFILE=65536
LimitNPROC=65536

[Install]
WantedBy=multi-user.target' > ~/prysmvalidator.service
echo $SU_PASSWORD | sudo -S cp ~/prysmvalidator.service /etc/systemd/system/prysmvalidator.service
rm ~/prysmvalidator.service

# rsyslog.d
echo 'if $programname == "prysmbeacon" then /home/amber/logs/prysmbeacon/prysmbeacon.log
if $programname == "prysmvalidator" then /home/amber/logs/prysmvalidator/prysmvalidator.log
& stop' > ~/prysm.conf
echo $SU_PASSWORD | sudo -S cp ~/pocket.conf /etc/rsyslog.d/prysm.conf
rm ~/prysm.conf

# logrotate
touch /home/amber/logs/prysmbeacon/prysmbeacon.log
touch /home/amber/logs/prysmvalidator/prysmvalidator.log

# start service
echo $SU_PASSWORD | sudo -S chmod 755 /etc/systemd/system/prysmbeacon.service
echo $SU_PASSWORD | sudo -S systemctl enable prysmbeacon.service
echo $SU_PASSWORD | sudo -S systemctl daemon-reload
echo $SU_PASSWORD | sudo -S service prysmbeacon start

echo $SU_PASSWORD | sudo -S chmod 755 /etc/systemd/system/prysmvalidator.service
echo $SU_PASSWORD | sudo -S systemctl enable prysmvalidator.service
echo $SU_PASSWORD | sudo -S systemctl daemon-reload
echo $SU_PASSWORD | sudo -S service prysmvalidator start