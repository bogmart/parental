
## crontab
#################################################################
crontab -l

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# one time, at boot
@reboot     /home/parental/scripts/cronPermitAny.sh

# 08:55
55 8 * * *   /home/parental/scripts/cronPermitAny.sh

# every minute
* * * * *   /home/parental/scripts/cronActiveWin.sh
#* * * * *   /home/parental/scripts/cronReportActiveWin.sh




## udev
#################################################################
# file: /etc/udev/rules.d/99-usb-mouse.rules
#bogmart:
# https://rufflewind.com/2014-06-24/auto-disable-touchpad-linux
#
# How to apply without reboot:
#   udevadm control --reload-rules && udevadm trigger
# How to debug:
#   udevadm monitor --kernel --property --subsystem-match=input

SUBSYSTEM=="input", KERNEL=="mouse[0-9]*", ACTION=="add", RUN+="/home/parental/scripts/reportActiveWin.sh"

