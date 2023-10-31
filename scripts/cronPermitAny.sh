#!/bin/bash

# crontab -e
#    0 9 * * *   /home/parental/scripts/cronPermitAny.sh 
#
# sudo less /var/spool/cron/crontabs/root


/usr/sbin/iptables -F

/home/parental/scripts/hostsUpd.sh -a allow -d youtube

/home/parental/scripts/appUpd.sh -a allow

## un-mute the audio devices
/home/parental/scripts/mediaControl.sh

