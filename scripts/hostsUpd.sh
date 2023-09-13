#!/bin/bash

# https://stackoverflow.com/questions/27690816/bash-script-to-comment-uncomment-lines-in-file

dstApp=youtube
action=deny

print_usage()
{
 echo "

 Description:
   This script updates the /etc/host file.
   The line that we want to be updated must contains a comment like 'deny-applicatio' e.g. 'deny-youtube'

 Options:
   -a <allow / deny>
       Action to do 
       default: ${action}
   -d <youtube / ...>
       Entry to be updated.
       default: ${dstApp}
 
  Examples:
        $(basename $0) -a allow -d youtube
      "
}
	   
while getopts "a:d:?" opt; do
  case $opt in
    a)
      action=${OPTARG}
      ;;
    d)
      dstApp=${OPTARG}
      ;;
    ?)
      print_usage
      exit 1
      ;;
  esac
done

#echo $dstApp

if [[ ${action} == "allow" ]]
then
  # comment
  sed -i -e "/^[0-9].*deny-${dstApp}/s/^/#/"   /etc/hosts
else
  # un-comment
  sed -i -e "/deny-${dstApp}/s/^#\+//" /etc/hosts
fi
