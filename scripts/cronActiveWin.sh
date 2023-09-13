#!/bin/bash

# crontab -u radu -e
#    * * * * * /home/parental/scripts/cronActiveWin.sh
#
# sudo less /var/spool/cron/crontabs/radu

logPath=/home/parental/logs
logFile="activeWin_$(date +"%Y-%m-%d_%a").txt"

/home/parental/scripts/activeWin.sh  >> ${logPath}/${logFile} 

/home/parental/scripts/cronReportActiveWin.sh

