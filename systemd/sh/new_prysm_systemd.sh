#!/bin/bash
# -n Server Number

SU_PASSWORD=''

# prysm beacon
echo '[Unit]
Description=Prysm Beacon chain daemon
After=network.target

[Service]
ExecStart=/home/amber/.eth2/prysm/prysm.sh beacon-chain --config-file=home/amber/.eth2/prysmbn.yaml
SyslogIdentifier=prysmbn
StartLimitInterval=0
LimitNOFILE=65536
LimitNPROC=65536
 
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
ExecStart=/home/amber/.eth2/prysm/prysm.sh validator --config-file=home/amber/.eth2/prysmvc.yaml
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