#!/bin/bash

libreOffice=`ls -1 /usr/share/applications/libreoffice*-base.desktop | awk -F '[/-]' '{print $5}'`

dstApp=("/opt/cxoffice/bin/wine" \
	"${libreOffice}" \
	"/opt/blender/blender" \
	"/opt/google/chrome/chrome" \
	"/snap/geforcenow-electron/17/geforcenow-electron" \
	"/opt/discord/Discord/Discord" \
	"firefox" \
	"java" \
	"vlc" \
       )

action=deny

print_usage()
{
 echo "

 Description:
   This script updates the execution flag of files.

 Options:
   -a <allow / deny>
       Action to do 
       default: ${action}
   -d <"vlc" "discord">
       Apps to be updated.
       default: ${dstApp[@]}
 
  Examples:
        $(basename $0) -a allow -d \"java vlc\" 
      "
}
	   
while getopts "a:d:?" opt; do
  case $opt in
    a)
      action=${OPTARG}
      ;;
    d)
      dstApp=("${OPTARG}")
      ;;
    ?)
      print_usage
      exit 1
      ;;
  esac
done


for app in ${dstApp[@]}; do
  appPath=$(whereis ${app} | awk '{print $2}' )
  if [ -z "${appPath}" ]
  then
    appPath=${app} 
  fi

  echo ${app} ${appPath}
  ls -la ${appPath}
  if [[ ${action} == "allow" ]]
  then
    chmod +x ${appPath}
  else
    chmod -x ${appPath}
    pkill -i $( echo ${app} | awk -F '/' '{print $NF}' )
  fi
done

