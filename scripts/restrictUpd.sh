#!/bin/bash

logPath=/home/parental/logs

holiday=0
noRestrictions=0

userLoggedIn=$(who | grep tty | awk '{print $1}')


if [[ "${userLoggedIn}" == "vlad" ]]
then
  # Vlad
  fun_MAX_school=45
  fun_MAX_holiday=90

  time_to_sleep_school="20:45"
  time_to_sleep_holiday="21:30"
  time_to_wakeup="08:55"
else
  # Radu
  fun_MAX_school=60
  fun_MAX_holiday=120

  time_to_sleep_school="21:45"
  time_to_sleep_holiday="22:30"
  time_to_wakeup="08:55"
fi


if [ $# -eq 0 ]
then
  logFileLast=`ls -1 ${logPath} | tail -n1`
else
  logFileLast=$1
fi


totalOnTime=`grep -c "On ::"  ${logPath}/${logFileLast}`

zoomTime=`cat ${logPath}/${logFileLast} | grep -v "Zoom Cloud Meetings" | grep -c ":: [zZ]oom"`

officeTime=`grep -cE ":: evince|soffice\.bin|featherpad|WINWORD\.EXE|POWERPNT\.EXE"   ${logPath}/${logFileLast}`

browsersTime=`grep -cE ":: chrome|firefox|_RUN" ${logPath}/${logFileLast}`
browsersActiveTime=`cat ${logPath}/${logFileLast} | grep -cE ":: chrome|firefox"`

chessStr=":: x.*[cC]hess\.com"
chessTime=`cat ${logPath}/${logFileLast}     | grep -oE "${chessStr}" | wc -l`

gamesWebStr="[aton|] CrazyGames|Grepolis|[rR]2[gG]ames.com|oskarstalberg|slither.io|Elvenar|wilds.io|Total Battle|Mars Tomorrow|Krunker|Play.*on Poki|iogameslist.org|https://(ro|en)..*/game|On.*s.l.o.w.*r.o.a.d.s"
gamesWebTime=`cat ${logPath}/${logFileLast}  | grep -cE "${gamesWebStr}"`

gamesAboutStr="steampowered\.com"
gamesAboutTime=`cat ${logPath}/${logFileLast}  | grep -cE "${gamesAboutStr}"`
# this value will be reduced by a factor of 2 on total funTime

learningStr=":: Duolingo|Naradix|iveworksheets|classroom\.google\.com|app\.programiz\.pro|scratch\.mit\.edu/projects/.*/editor|poezii-pentru-copii"
learningTime=`cat ${logPath}/${logFileLast}  | grep -oE ":: x.*(${learningStr})" | uniq | wc -l`

meetTime=`cat ${logPath}/${logFileLast}      | grep ":: Meet " | grep -vcE "[zZ]oom"`

moviesStr="movies|videos|[vV]iki"
moviesTime=`cat ${logPath}/${logFileLast}    | grep -cE "${moviesStr}"`

whatsAppTime=`cat ${logPath}/${logFileLast}  | grep -c ":: WhatsApp"`

youtubeStr="YouTube"
youtubeWhiteListStr="[hH]ow [tT]o [dD]raw"
youtubeTime=`cat ${logPath}/${logFileLast}   | grep "${youtubeStr}" | grep -cvE "${youtubeWhiteListStr}"`

geForceStr="on GeForce NOW"
geForceTime=`cat ${logPath}/${logFileLast}   | grep -c "${geForceStr}"`

minecraftStr="java :: Minecraft|java :: WorldPainter"
minecraftTime=`cat ${logPath}/${logFileLast} | grep -cE "${minecraftStr}"`

discordTime=`cat ${logPath}/${logFileLast}   | grep -cE " Discord "`

funStr="${chessStr}|${gamesWebStr}|${moviesStr}|${youtubeStr}|${geForceStr}|${minecraftStr}"

funTimeWeb=$(( ${chessTime} + ${gamesWebTime} + $(( ${gamesAboutTime} / 2 )) + ${moviesTime} + ${youtubeTime} ))
funTimeApp=$(( ${geForceTime} + ${minecraftTime} ))
funTime=$(( ${funTimeWeb} + ${funTimeApp} ))

relaxTimeWeb=$(( ${browsersTime} - ${learningTime} - ${funTimeWeb} - ${whatsAppTime} ))

echo "Total_On     " ${totalOnTime}
echo "  Fun_total  " ${funTime}
echo "  Web_others " ${relaxTimeWeb}
echo "---------------------"
if [ ${zoomTime}       -ne 0 ] ; then  echo "Zoom          " ${zoomTime}      ; fi
if [ ${officeTime}     -ne 0 ] ; then  echo "Office        " ${officeTime}    ; fi
if [ ${browsersTime}   -ne 0 ] ; then  echo "Browsers_Web  " ${browsersTime} "  (active" ${browsersActiveTime} ")" ; fi
if [ ${chessTime}      -ne 0 ] ; then  echo "  Chess       " ${chessTime}     ; fi
if [ ${gamesWebTime}   -ne 0 ] ; then  echo "  Games_Web   " ${gamesWebTime}  ; fi
if [ ${gamesAboutTime} -ne 0 ] ; then  echo "  Games_About " ${gamesAboutTime}; fi
if [ ${learningTime}   -ne 0 ] ; then  echo "  Learning    " ${learningTime}  ; fi
if [ ${meetTime}       -ne 0 ] ; then  echo "  Meet        " ${meetTime}      ; fi
if [ ${moviesTime}     -ne 0 ] ; then  echo "  Movies      " ${moviesTime}    ; fi
if [ ${whatsAppTime}   -ne 0 ] ; then  echo "  WhatsApp    " ${whatsAppTime}  ; fi
if [ ${youtubeTime}    -ne 0 ] ; then  echo "  YouTube     " ${youtubeTime}   ; fi
if [ ${geForceTime}    -ne 0 ] ; then  echo "GeForce       " ${geForceTime}   ; fi
if [ ${minecraftTime}  -ne 0 ] ; then  echo "Minecraft     " ${minecraftTime} ; fi
if [ ${discordTime}    -ne 0 ] ; then  echo "Discord       " ${discordTime}   ; fi

exit 0

# apply restrictions only for current day (no params)
if [ $# -eq 0 ]
then
  # if PC just started, then clear all persistent settings
  upTime=`awk '{print int($1/60)}' /proc/uptime`
  if [ ${upTime} -lt 2 ]
  then
    /home/parental/scripts/hostsUpd.sh -a allow -d youtube
  fi

  currentTime=$(date +%H:%M)  # HH:MM
  dayOfWeek=$(date +%u)       # 1..7; 1 is Monday

  funMaxTime=${fun_MAX_school}
  gotoSleepTime=${time_to_sleep_school}

  # Friday or Saturday 
  if [ ${dayOfWeek} -eq 5 -o ${dayOfWeek} -eq 6 -o ${holiday} -eq 1 ]
  then
    funMaxTime=${fun_MAX_holiday}
    gotoSleepTime=${time_to_sleep_holiday}
  fi

  # max time for relax
  relaxMaxTime=$(( ${funMaxTime} * 3 / 2 ))

  #echo ${funTime} ${funMaxTime} >> /tmp/tmp.txt
  if [ ${funTime}         -gt ${funMaxTime}         ] ||  \
     [ ${relaxTimeWeb}    -gt ${relaxMaxTime}       ] ||  \
     [[ "$currentTime"     > "${gotoSleepTime}"    ]] ||  \
     [[ "$currentTime"     < "${time_to_wakeup}"   ]]
  then
    /home/parental/scripts/quota.sh &
    /home/parental/scripts/hostsUpd.sh -a deny -d youtube

    lastActiveEntry=`tail -n1 ${logPath}/${logFileLast}`
    if [ `echo ${lastActiveEntry} | grep -cE "${funStr}"` -eq 1 ]
    then
      if [ `echo ${lastActiveEntry} | grep -cE ":: firefox|FIREFOX_RUN"` -eq 1 ]
      then
        killall firefox
      elif [ `echo ${lastActiveEntry} | grep -cE ":: chrome|CHROME_RUN"` -eq 1 ]
      then
        killall chrome
      elif [ `echo ${lastActiveEntry} | grep -c ":: java"` -eq 1 ]
      then
        killall java
      fi
    fi  
  fi
fi

#cat `ls -1 | tail -n1` | awk -F' ::' '{print $5}' | sed "s/^ //;s/.* - YouTube/YouTube/;s/Meet - .*/Meet/" | sort | uniq

