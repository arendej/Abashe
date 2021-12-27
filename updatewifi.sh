#!/bin/bash
# Checks for sudo, and then updates my wifi driver for my not yet kernel supported 
# Lenovo AMD T14 laptop with realtek rtw89 chipset for wifi.
# It's not super convenient but that's why I made this script to run if a
# kernel update happens.

# change the user var to your own.
# depends on the repo having been cloned already.

MYUSER=adj

CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
if [ ${CAN_I_RUN_SUDO} -gt 0 ]
then
   echo -e "\nSudo available..\nUpdating wifi driver."
   if [[ "$1" == "--offline" || "$1" == "-offline" ]];
    then
     mkdir -p /home/$MYUSER/rtw89 && cd /home/$MYUSER/rtw89
     make clean
     make && sudo make install
     sudo modprobe rtw89pci
    else
     mkdir -p /home/$MYUSER/rtw89 && cd /home/$MYUSER/rtw89
     make clean
     git pull && make && sudo make install
     sudo modprobe rtw89pci
   fi
else
    echo "Sudo not available.. exiting"
    exit 1
fi

#cd ~/rtw89 && git pull && make && sudo make install
