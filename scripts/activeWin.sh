#!/bin/bash

userLoggedIn=$(who | grep tty | awk '{print $1}')

export DISPLAY=:0.0
export XAUTHORITY=/home/${userLoggedIn}/.Xauthority
#export XDG_RUNTIME_DIR=/run/user/1000

#remove browsers' suffixes
browser_name_clean=( sed -E 's/ [^[:alnum:]]+ Mozilla Firefox//;s/ [^[:alnum:]]+ Google Chrome//' )

#win are active
firefoxActiveTab=""
chromeActiveTab=""

#(win is not the active one) and (win is NOT minimized)
firefoxVisibleTab=""
chromeVisibleTab=""

separator="::"

function firefox_url_get {
  local tab_name=$(python3 /home/parental/scripts/ff.py ${userLoggedIn})
  eval "$1='${tab_name}'"
}

function chrome_url_get {
  local sessionFileLatest=$(ls -1t /home/${userLoggedIn}/.config/google-chrome/Default/Sessions/Session_* | head -n1)
  local tab_name=$(python3 /home/parental/Chromagnon/chromagnonSession.py ${sessionFileLatest} | grep "UpdateTabNavigation" | tail -n1 | sed 's/.*- Tab/Tab/')
  eval "$1='${tab_name}'"
}

monitorState=$(xset -q | grep -E "Monitor is|DPMS is Disabled" | awk "{print \$3}")

echo -n ${monitorState} ${separator} $(date +"%Y.%m.%d-%H.%M.%S") "${separator} "

if [[ "${monitorState}" == "On" || "${monitorState}" == "Disabled" ]] ; then
  mousePosition=$(xdotool getmouselocation | sed 's/ scree.*//')

  active_window_id=$(xdotool getactivewindow)
  if [[ "${active_window_id}" == "" ]] ; then
    active_window_id=$(xdotool getwindowfocus)
  fi
  if [[ "${active_window_id}" == "" ]] ; then
    active_window_id=$(xprop -root | grep -m1 "^_NET_ACTIVE_WINDOW" | cut -d" " -f5)
  fi

  #if [ "${active_window_id}" = "" ] ; then
  #  active_window_id=$(xprop -root  | grep -m1 "^_NET_ACTIVE_WINDOW" | cut -d" " -f5)
  #  active_proc_name=$(xprop -id ${active_window_id} | grep "^_OB_APP_GROUP_NAME" | cut -d" " -f3)
  #  active_proc_name=$(xprop -id ${active_window_id} | grep "^_OB_APP_GROUP_NAME" | cut -d" " -f3)
  #fi

  active_window_pid=$(xdotool getwindowpid ${active_window_id})
  active_window_name=$(xdotool getwindowname ${active_window_id} | "${browser_name_clean[@]}")
  active_proc_name=$(cat /proc/${active_window_pid}/comm)

  echo -n ${mousePosition} ${separator} ${active_proc_name} ${separator} ${active_window_name} ${separator} 

  if [[ "${active_proc_name}" == "firefox" ]] ; then
    firefox_url_get firefoxActiveTab
    echo -n "" ${firefoxActiveTab}
  fi
  if [[ "${active_proc_name}" == "chrome" ]] ; then
    chrome_url_get chromeActiveTab
    echo -n "" ${chromeActiveTab}
  fi

  #lookup for maximized browsers
  firefoxRunsVisible=$(xdotool search --onlyvisible --name firefox)
  if [[ "${firefoxRunsVisible}" != "" ]] ; then
    echo -n "" ${separator} "FIREFOX_RUN"
    for winIterator in ${firefoxRunsVisible}
    do
      firefox_window_name=$(xdotool getwindowname ${winIterator} | "${browser_name_clean[@]}")
      echo -n "" ${separator} ${firefox_window_name}
    done
    firefox_url_get firefoxVisibleTab
    echo -n "" ${separator} ${firefoxVisibleTab}
  fi

  chromeRunsVisible=$(xdotool search --onlyvisible --name chrome)
  if [[ "${chromeRunsVisible}" != ""  ]] ; then
    echo -n "" ${separator} "CHROME_RUN"
    for winIterator in ${chromeRunsVisible}
    do
      chrome_window_name=$(xdotool getwindowname ${winIterator} | "${browser_name_clean[@]}")
      chrome_url_get chromeVisibleTab
      echo -n "" ${separator} ${chrome_window_name} ${separator} ${chromeVisibleTab}
    done
  fi

fi

echo  ""
