#!/bin/bash
# -n Server Number

SU_PASSWORD=''
while getopts ":p:h" optname
do
    case "$optname" in
      "p") SU_PASSWORD=$OPTARG ;;
      "h") echo "new_prysm_systemd.sh -p <password>" ;;
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
User=amber
Restart=always
RestartSec=5s
ExecStart=/home/amber/.eth2/prysm/prysm.sh beacon-chain --config-file=home/amber/.eth2/conf/prysmbn.yaml

KillMode=process
KillSignal=SIGINT
TimeoutStopSec=90
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=prysmbn


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
User=amber
Restart=always
RestartSec=5s

ExecStart=/home/amber/.eth2/prysm/prysm.sh validator --config-file=home/amber/.eth2/conf/prysmvc.yaml

KillMode=process
KillSignal=SIGINT
TimeoutStopSec=90
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=prysmvc

[Install]
WantedBy=multi-user.target' > ~/prysmvc.service
echo $SU_PASSWORD | sudo -S cp ~/prysmvc.service /etc/systemd/system/prysmvc.service
rm ~/prysmvc.service

rsync -a ../conf /home/amber/.eth2/conf/prysmbn.yaml

# rsyslog.d
echo 'if $programname == "prysmbn" then /home/amber/logs/prysmbn/prysmbn.log
if $programname == "prysmvc" then /home/amber/logs/prysmvc/prysmvc.log
& stop' > ~/prysm.conf
echo $SU_PASSWORD | sudo -S cp ~/prysm.conf /etc/rsyslog.d/prysm.conf
rm ~/prysm.conf

# logrotate
touch -c /home/amber/logs/prysmbn/prysmbn.log
touch -c /home/amber/logs/prysmvc/prysmvc.log

# start service
echo $SU_PASSWORD | sudo -S chmod 755 /etc/systemd/system/prysmbn.service
echo $SU_PASSWORD | sudo -S systemctl enable prysmbn.service
echo $SU_PASSWORD | sudo -S systemctl daemon-reload
echo $SU_PASSWORD | sudo -S service prysmbn start

echo $SU_PASSWORD | sudo -S chmod 755 /etc/systemd/system/prysmvc.service
echo $SU_PASSWORD | sudo -S systemctl enable prysmvc.service
echo $SU_PASSWORD | sudo -S systemctl daemon-reload
echo $SU_PASSWORD | sudo -S service prysmvc start