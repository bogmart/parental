#!/bin/bash

# crontab -u root -e
#    */5 * * * * /home/parental/scripts/cronReportActiveWin.sh
#
# sudo less /var/spool/cron/crontabs/root

userLoggedIn=$(who | grep tty | awk '{print $1}')

reportPath=/home/${userLoggedIn}/Desktop
reportFile="REPORT.txt"

/home/parental/scripts/reportActiveWin.sh > ${reportPath}/${reportFile}
