#!/bin/bash

quotaVal=0 # bytes

appsToCheck="chrome|Discord|firefox|geforcenow-elec|java"

whiteListCidr="/home/parental/scripts/white_list_ip.txt"

whiteListDynUrl="www.duolingo.com liveworksheets.com  matemanieplus.ro  mail.yahoo.com ir2.yahoo.com geo.yahoo.com  web.whatsapp.com x.thunkable.com thunkable.com"
declare -a whiteListDynIP=(`getent ahosts ${whiteListDynUrl} | cut -d" " -f1 | sort -u`)
#echo ${whiteListDynIP[@]}

## remove existing rules for dynamic IPs
for dynIp in "${whiteListDynIP[@]}"
do
  iptables -D INPUT -s ${dynIp} -j DROP > /dev/null 2>&1
done


## declare an array variable
#declare -a serversIP=(`netstat -tunp | grep -E "ESTABLISHED.*(${appsToCheck})" | awk '{ print $5 }' | cut -d: -f1 | sort -u`)
declare -a serversIP=(`lsof +c0 -nP -i4tcp -sTCP:ESTABLISHED | grep -E "${appsToCheck}" | awk -F'[>: ]+' '{ print $11 }' | sort -u`)
RC=0

for ip in "${serversIP[@]}"
do

  ## Do nothing if there is an existing rule for this IP address
  if `iptables -L INPUT -n | grep ${ip} > /dev/null 2>&1`; then
    continue
  fi

  if `grepcidr -f ${whiteListCidr}  <(echo "${ip}") >/dev/null 2>&1`; then
    #echo "${ip} is in white list"
    continue
  fi

  if [ `echo ${whiteListDynIP[@]} | grep -cE "${ip}( |$)"` -eq 1 ]; then
    #echo "${ip} is in dynamic URL white list"
    continue
  fi

  #echo ${ip}
  if [ ${quotaVal} -ne 0 ] ; then
    iptables -A INPUT -s ${ip} -m quota --quota ${quotaVal} -j ACCEPT -c 0 0
  fi
  iptables -A INPUT -s ${ip} -j DROP
  RC=$?
done

exit $RC
## EOF
