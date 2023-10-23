#!/bin/bash

logPath=/home/parental/logs

holiday=0

userLoggedIn=$(who | grep tty | awk '{print $1}')


active_max_duration=45
break_duration=15

if [[ "${userLoggedIn}" == "vlad" ]]
then
  # Vlad
  fun_MAX_school=45
  fun_MAX_weekend=75
  fun_MAX_holiday=120

  others_MAX_coefficient="3 / 2"

  time_to_sleep_school="20:45"
  time_to_sleep_weekend="21:30"
  time_to_sleep_holiday="20:30"

  time_to_wakeup="08:55"
else
  # Radu
  fun_MAX_school=60
  fun_MAX_weekend=90 
  fun_MAX_holiday=180

  others_MAX_coefficient="3 / 2"
  
  time_to_sleep_school="21:45"
  time_to_sleep_weekend="22:30"
  time_to_sleep_holiday="20:30"

  time_to_wakeup="07:55"
fi



if [ $# -eq 0 ]
then
  logFileLast=`ls -1 ${logPath} | tail -n1`
else
  logFileLast=$1
fi


totalOnStr="On ::"
totalIdleStr="pcmanfm-qt ::$|Openbox ::$"
totalActiveTime=`cat ${logPath}/${logFileLast} | grep "${totalOnStr}" | grep -cvE "${totalIdleStr}"`

zoomTotalStr=":: [zZ]oom"
zoomConnectingStr="Zoom Cloud Meetings"
zoomTime=`cat ${logPath}/${logFileLast} | grep "${zoomTotalStr}" | grep -cv "${zoomConnectingStr}"`

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

learningStr=":: Duolingo|Naradix|iveworksheets|classroom\.google\.com|docs\.google\.com/forms|geogra.ro|app\.programiz\.pro|Online lesson|learn.alg.academy|scratch\.mit\.edu/projects/.*/editor|poezii-pentru-copii"
learningTime=`cat ${logPath}/${logFileLast}  | grep -oE ":: x.*(${learningStr})" | uniq | wc -l`

meetTime=`cat ${logPath}/${logFileLast}      | grep ":: Meet " | grep -vcE "[zZ]oom"`

moviesStr=":: vlc ::|lookmovie2| movies|videos|/video/|[vV]iki|IEVENN"
moviesTime=`cat ${logPath}/${logFileLast}    | grep -cE "${moviesStr}"`

whatsAppTime=`cat ${logPath}/${logFileLast}  | grep -c ":: WhatsApp"`

youtubeStr="YouTube"
youtubeWhiteListStr="[hH]ow [tT]o [dD]raw|[dD]rawing|[çÇ]izim|[aA]lphabet|ABC [sS]ong"
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

othersTimeWeb=$(( ${browsersTime} - ${learningTime} - ${funTimeWeb} - ${whatsAppTime} ))

echo "Total_active  " ${totalActiveTime}
echo "  Fun_total   " ${funTime}
echo "  Web_others  " ${othersTimeWeb}
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




# apply restrictions only for current day (no params)
if [ $# -eq 0 ]
then
  ### if PC just started, then clear all persistent settings
  ### see /etc/profile.d/99-restrictions-clear.sh
  # upTime=`awk '{print int($1/60)}' /proc/uptime`
  # if [ ${upTime} -lt 2 ]
  # then
  #   /home/parental/scripts/hostsUpd.sh -a allow -d youtube
  # fi

  currentTime=$(date +%H:%M)  # HH:MM
  dayOfWeek=$(date +%u)       # 1..7; 1 is Monday

  funMaxTime=${fun_MAX_school}
  gotoSleepTime=${time_to_sleep_school}

  if [ ${holiday} -eq 1 ]
  then
    funMaxTime=${fun_MAX_holiday}
    gotoSleepTime=${time_to_sleep_holiday}
  else
    # Friday or Saturday 
    if [ ${dayOfWeek} -eq 5 -o ${dayOfWeek} -eq 6 ]
    then
      funMaxTime=${fun_MAX_weekend}
      gotoSleepTime=${time_to_sleep_weekend}
    fi
  fi

  # max time for "others"
  othersMaxTime=$(( ${funMaxTime} * ${others_MAX_coefficient} ))

  #echo funTime: ${funTime} funMaxTime: ${funMaxTime}  othersMaxTime: ${othersMaxTime} >> /tmp/tmp.txt


  if [ ${funTime}         -gt ${funMaxTime}         ] ||  \
     [ ${othersTimeWeb}   -gt ${othersMaxTime}      ] ||  \
     [[ "${currentTime}"   > "${gotoSleepTime}"    ]] ||  \
     [[ "${currentTime}"   < "${time_to_wakeup}"   ]]
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
      elif [ `echo ${lastActiveEntry} | grep -c ":: vlc"` -eq 1 ]
      then
        /home/parental/scripts/appUpd.sh -a deny -d vlc
        killall vlc
      fi
    else
      if [ `echo ${lastActiveEntry} | grep -c ":: blender"` -eq 1 ]
      then
        /home/parental/scripts/appUpd.sh -a deny -d  /opt/blender/blender
      fi
    fi
  fi
fi



export DISPLAY=:0.0
export XAUTHORITY=/home/${userLoggedIn}/.Xauthority
export XDG_RUNTIME_DIR=/run/user/1000

default_desktop_mngr="pcmanfm-qt"


function sayMessage {
  msg="$1" 

  amixer -q set Master unmute
  amixer -q set Speaker unmute

  sound_volume_cur=`amixer get Master | awk '/dB/{printf $3}'`
  if [ ${sound_volume_cur} -lt 60 ]
  then
    amixer -q set Master 60
  fi

   su ${userLoggedIn} -c "espeak '${msg}' -s 100 -a 300  -v en-us"
} 

function blockAnyActiv {
  ### de-activate keyboard, mouse, tablet, etc
  while IFS= read -r device_id
  do
    xinput set-prop ${device_id} 'Device Enabled' 0
  done < <(xinput list --short | grep -vE "master|Power|Sleep|Video|Virtual" | grep -oE "id=([0-9]*)" | awk -F '=' '{print $2}')

  ### pause players
  xdotool key space

  ### mute sound
  amixer -q set Speaker mute

  ### mute bluetooth
  # pactl set-sink-mute @DEFAULT_SINK@ 1

  ### minimize all windows
  window_active=`xdotool getactivewindow getwindowname`
  if [[ "${window_active}" != "${default_desktop_mngr}" ]]
  then 
    xdotool key super+d
  fi

  ### turn monitor OFF
  xset dpms force off
}

function unblockActiv {
  ### check if monitor is locked by script (or real idle)
  keyboard_is_enable=`xinput list-props 'AT Translated Set 2 keyboard' | awk '/Device Enabled/{print $NF}'`
  if [ ${keyboard_is_enable} -eq 0 ]
  then
    ### activate keyboard, mouse, tablet, etc
    while IFS= read -r device_id
    do
      xinput set-prop ${device_id} 'Device Enabled' 1
    done < <(xinput list --short | grep -vE "master|Power|Sleep|Video|Virtual" | grep -oE "id=([0-9]*)" | awk -F '=' '{print $2}')

    ### un-mute bluetooth
    # pactl set-sink-mute @DEFAULT_SINK@ 0

    ### turn monitor ON
    xset dpms force on
  fi
}




  monitorState=$(xset -q | grep -E "Monitor is|DPMS is Disabled" | awk "{print \$3}")

  ### get active time in the last period (active + break) -- usually 60 minutes 
  active_duration=`tail -n $(( ${active_max_duration} + ${break_duration} ))  ${logPath}/${logFileLast} | grep "${totalOnStr}" | grep -cvE "${totalIdleStr}"`

  echo "---------------------"
  echo "Current_active" ${active_duration} "  (max" ${active_max_duration} "+ break" ${break_duration}")"


  time_zone=`date +%Z`
  timeSaySleep=`date +%H:%M  -d "${gotoSleepTime} ${time_zone} +1 min"`
  if [[ "${currentTime}" > "${timeSaySleep}"    ]]
  then
    if [[ "${monitorState}" == "On" || "${monitorState}" == "Disabled" ]]
    then
      sayMessage "It is time to sleep! Please save your work!"

      timeBlockActiv=`date +%H:%M  -d "${gotoSleepTime} ${time_zone} +5 min"`
      if [[ "${currentTime}" > "${timeBlockActiv}" ]]
      then
        blockAnyActiv
      fi
    fi

  elif [ ${active_duration} -ge $(( ${active_max_duration} -1 )) ]
  then
    if [[ "${monitorState}" == "On" || "${monitorState}" == "Disabled" ]]
    then
      zoom_active=`xdotool search  --name "Zoom Meeting"`
      if [[ "${zoom_active}" == "" ]]
      then
        if [ ${active_duration} -eq $(( ${active_max_duration} -1 )) ]
        then
	  active_next_duration=`tail -n $(( ${active_max_duration} -1 + ${break_duration} ))  ${logPath}/${logFileLast} | grep "${totalOnStr}" | grep -cvE "${totalIdleStr}"`
	  if [ ${active_next_duration} -eq $(( ${active_max_duration} -1 )) ]
          then
            sayMessage "It is time for a break!"
          fi
        else
          blockAnyActiv
        fi
      fi
    fi
  elif [ ${active_duration} -le $(( ${active_max_duration} - 2 )) ]
  then
    if [[ "${monitorState}" == "Off" ]]
    then
      unblockActiv 
    fi
  fi

