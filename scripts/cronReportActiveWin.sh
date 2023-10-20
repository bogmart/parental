#!/bin/bash

# crontab -u root -e
#    */5 * * * * /home/parental/scripts/cronReportActiveWin.sh
#
# sudo less /var/spool/cron/crontabs/root

userLoggedIn=$(who | grep tty | awk '{print $1}')

reportPath=/home/${userLoggedIn}/Desktop
reportFile="REPORT.txt"

# Do not update the report synchronously with the sampling times (in order to avoid cheating)
min=5  #seconds
max=50
sleep  $(($RANDOM%($max-$min+1)+$min))
/home/parental/scripts/reportActiveWin.sh > ${reportPath}/${reportFile}
