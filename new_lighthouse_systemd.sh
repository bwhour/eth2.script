#!/bin/bash
# -n Server Number

SERVER_NUMBER=0
SU_PASSWORD='&kHLJ2h#zQ&BSIuH'

while getopts ":n:a:h" optname
do
    case "$optname" in
      "n") SERVER_NUMBER=$OPTARG ;;
      "a") SU_PASSWORD=$OPTARG ;;
      "h") echo "new_lighthouse_systemd.sh -n 1-a <password>" ;;
      ":") echo "No argument value for option $OPTARG" ;;
      "?") echo "Unknown option $OPTARG" ;;
      *) echo "Unknown error while processing options" ;;
    esac
    # echo "option index is $OPTIND"
done

# lighthouse beacon
echo '[Unit]
Description=Lighthouse: Ethereum 2.0 Beacon Node
After=syslog.target network.target

[Service]
User=amber
Type=simple
ExecStart=/usr/local/bin/lighthouse  bn   \
  --network prater   \
  --datadir /home/amber/.eth2  \
  --subscribe-all-subnets \
  --target-peers 80 \
  --staking   \
  --http      \
  --http-allow-sync-stalled     \
  --eth1-endpoints https://blockchain-beta.amberainsider.com/goerli,https://apis.ankr.com/71f4b42d70a54565894113da390ec08b/c942b301ab4cd3e91c05afbc7c0ab06f/eth/fast/goerli,https://rpc.goerli.mudit.blog    \
  --metrics     \
  --validator-monitor-auto
KillMode=process
KillSignal=SIGINT
TimeoutStopSec=90
Restart=on-failure
RestartSec=5s
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=lighthousebn

[Install]
WantedBy=multi-user.target' > ~/lighthousebn.service
echo $SU_PASSWORD | sudo -S cp ~/lighthousebn.service  /etc/systemd/system/lighthousebn.service
rm ~/lighthousebn.service

# lighthouse validator
echo '[Unit]
Description=Lighthouse: Ethereum 2.0 Validator Client
After=syslog.target network.target

[Service]
User=amber
Type=simple
ExecStart=/usr/local/bin/lighthouse vc \
  --network prater \
  --metrics \
  --datadir /home/amber/.eth2/lighthousevc \
  --graffiti Amber \
  --suggested-fee-recipient 0xddF96802613aF354dcC1cb1A32910d6d997E54b0
KillMode=process
KillSignal=SIGINT
TimeoutStopSec=90
Restart=always
RestartSec=5s
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=lighthousevc

[Install]
WantedBy=multi-user.target' > ~/lighthousevc.service
echo $SU_PASSWORD | sudo -S cp ~/lighthousevc.service /etc/systemd/system/lighthousevc.service
rm ~/lighthousevc.service

# rsyslog.d
echo 'if $programname == "lighthousebn" then /home/amber/logs/lighthousebn/lighthousebn.log
if $programname == "lighthousevc" then /home/amber/logs/lighthousevc/lighthousevc.log
& stop' > ~/lighthouse.conf
echo $SU_PASSWORD | sudo -S cp ~/lighthouse.conf /etc/rsyslog.d/lighthouse.conf
rm ~/lighthouse.conf

# logrotate
touch /home/amber/logs/lighthousebn/lighthousebn.log
touch /home/amber/logs/lighthousevc/lighthousevc.log

# start service
echo $SU_PASSWORD | sudo -S chmod 755 /etc/systemd/system/lighthousebn.service
echo $SU_PASSWORD | sudo -S systemctl enable lighthousebn.service
echo $SU_PASSWORD | sudo -S systemctl daemon-reload
echo $SU_PASSWORD | sudo -S service lighthousebn start

echo $SU_PASSWORD | sudo -S chmod 755 /etc/systemd/system/lighthousevc.service
echo $SU_PASSWORD | sudo -S systemctl enable lighthousevc.service
echo $SU_PASSWORD | sudo -S systemctl daemon-reload
echo $SU_PASSWORD | sudo -S service lighthousevc start