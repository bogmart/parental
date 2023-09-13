#!/bin/bash

userLoggedIn=$(who | grep tty | awk '{print $1}')

sessionFileLatest=$(ls -1t /home/${userLoggedIn}/.config/google-chrome/Default/Sessions/Session_* | head -n1)

echo "old: "
python2 /home/parental/Chromagnon_old/chromagnonSession.py ${sessionFileLatest} | grep "UpdateTabNavigation" | tail -n1 | sed 's/.*- Tab/Tab/'
echo "new: "
python3 /home/parental/Chromagnon/chromagnonSession.py ${sessionFileLatest} | grep "UpdateTabNavigation" | tail -n1 | sed 's/.*- Tab/Tab/;s/  / /'



