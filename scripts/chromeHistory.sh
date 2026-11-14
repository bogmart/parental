#!/bin/bash

source /home/parental/scripts/userLoggedIn

chromeHistory=/home/${userLoggedIn}/.config/google-chrome/Default/History
chromeTmpHistory=/tmp/chrome_history_tmp

cp ${chromeHistory} ${chromeTmpHistory}

python3 /home/parental/Chromagnon/chromagnonHistory.py -s $(date +"%m/%d/%Y") ${chromeTmpHistory} -c vt vc tc tl u $@

rm ${chromeTmpHistory}

