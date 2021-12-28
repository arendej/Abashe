#!/bin/bash
# get-git.sh -- by funixz -- https://github.com/funixz
# Retrieves latest version of git and installs from source if you allow it.
# - Debian requires these installed: libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev build-essential autoconf
# - RHEL/ Centos requires these installed: gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel gcc autoconf
# - built on Debian 8 & CentOS 7
# - run with sudo/root
# - try to make sure there's no prior git files in /tmp before running.
##################################################################################
set -x
#global variables

#loccurgitver="v$(/usr/local/bin/git --version|cut -d ' ' -f 3)"
cgitver="v$($(which git) --version|cut -d ' ' -f 3)"
usrbingitver="v$(/usr/bin/git --version|cut -d ' ' -f 3)"
wgit=$(which git)
#cgitver="v2.16.0-rc1" #for testing
#old# latest=$(curl https://github.com/git/git/releases -s | grep archive | grep '.tar.gz' | cut -d \" -f 4 | head -n 1 | cut -d \/ -f 5 |sed 's/.tar.gz//')
latest="$(curl https://github.com/git/git/tags -s| grep [0-9].tar.gz| cut -d \" -f 4|head -n 1 | cut -d \/ -f 7 | sed 's/.tar.gz//')"
wdir="$(curl https://github.com/git/git/tags -s| grep [0-9].tar.gz| cut -d \" -f 4|head -n 1 | cut -d \/ -f 7  |sed 's/v//' |sed 's/.tar.gz//')"
OS=""

#functions

gitreport() {
	cgitver="v$(/usr/local/bin/git --version|cut -d ' ' -f 3)"
	#loccurgitver="v$($(which git) --version|cut -d ' ' -f 3)"
	wgit="$(which git)"
	echo -e "Default Stock Git $cgitver, found at $wgit ."
	#echo -e "\nLocal Git version is $loccurgitver, found at /usr/local/bin/git ."
	echo -e "\nAlternate Git, found at /usr/bin/git, is $usrbingitver."
	echo -e "\nYou may opt to use a specific one and remove the other,\nor rely on the default found at $wgit.\n"
}

upgradegitDeb() {
echo -e "\nUpgrading Git on Debian..."
echo "Going from -- v$cgitver -- to -- v$latest --. \n"
newlink="https://github.com/git/git/archive/refs/tags/v$latest.tar.gz"
#-----
echo "pulling from $newlink"
cd /tmp && wget --show-progress $newlink
cd /tmp && tar -xzf $(curl https://github.com/git/git/tags -s| grep [0-9].tar.gz | cut -d \" -f 4 | head -n 1 | cut -d \/ -f 7)
cd /tmp/git-$wdir && make --silent configure >> /tmp/git-from-source.log 2>&1
cd /tmp/git-$wdir && ./configure
cd /tmp/git-$wdir && make --silent prefix=/usr/local all > /tmp/git-from-source.log 2>&1
cd /tmp/git-$wdir && make --silent prefix=/usr/local install > /tmp/git-from-source.log 2>&1
#-----
gitreport;
}

upgradegitRHF() {
echo -e "\nInstalling dependencies.."
yum -q groupinstall -y "Development Tools"
yum -q install -y wget gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel gcc autoconf
echo -e "\nUpgrading Git on RHEL/Fedora ..."
echo -e "Going from -- $cgitver -- to -- $latest --. \n"
newlink="https://github.com/git/git/archive/refs/tags/$latest.tar.gz"
#-----
echo "pulling from $newlink"
cd /tmp && wget --progress=bar:force $newlink
cd /tmp && tar -xzf $(curl https://github.com/git/git/tags -s| grep [0-9].tar.gz | cut -d \" -f 4 | head -n 1 | cut -d \/ -f 7)
cd /tmp/git-$wdir && make --silent configure >> /tmp/git-from-source.log 2>&1
cd /tmp/git-$wdir && ./configure --prefix=/usr/local
cd /tmp/git-$wdir && make --silent install > /tmp/git-from-source.log 2>&1
#-----
gitreport;
}

#end-functions
#main

# help parameter handling - if asking for help or , then show it.
if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [[ -n "$1" && "$1" != "-y" ]]; then
   echo -e "--------------------------------------------------------------------------------"
   echo " get-git.sh -- by arendej -- https://github.com/arendej"
   echo -e " Retrieves latest version of git from GitHub  and installs from source if you\nallow it."
   echo "  - run with sudo/root"
   echo "  - make sure there's no prior git related files/folders in /tmp before running."
   echo -e "  - currently accepts '-h' or '--help' for help and '-y' to upgrade\nwithout prompt"
   echo -e "--------------------------------------------------------------------------------\n"
else

   echo -e "\nCurrent default Git is .... $cgitver ($(which git))."
   echo -e "Latest Git on github.com is $latest \n"

   # discover Debian or CentOS
   if [[ -f "/etc/debian-version" && $(cat /etc/debian-version |grep "8.") ]]; then # if Debian 8 or newer
     OS="Deb"
   elif [[ -f "/etc/redhat-release" && $(cat /etc/redhat-release |grep " 7.") ]]; then # if RHEL 7 or newer
     OS="RCE"
   elif [[ -f "/etc/redhat-release" && $(cat /etc/redhat-release |grep " 8.") ]]; then # if RHEL 8 or newer
     OS="RCE"
   elif [ -f "/etc/redhat-release" ] && (( $(cat /etc/redhat-release |grep Fedora |awk '{print$3}') > 21 )); then # if newer than F21
     OS="RCE"
   fi

   if [ "$cgitver" = "$latest" ]; then
      echo "Current Git matches latest available; Exiting."
      exit 0
   elif [[ "$cgitver" != "$latest" && "$1" != "-y" ]]; then
      echo "Newer git available. Upgrade? [y/n]:"
      read upg
      if [[ "$upg" = "y" || "$upg" = "Y" ]]; then
         if [[ "$OS" = "RCE" ]]; then
           upgradegitRHF;
         elif [[ "$OS" = "Deb" ]]; then
           upgradegitDeb;
         else
           echo "Unknown OS. Expecting RHEL 7/8, Fedora 21+ or Debian 8; Exiting."
           exit 1
         fi
      else
         echo "No upgrade to take place; Exiting."
         exit 0
      fi
   elif [[ "$cgitver" != "$latest" && "$1" == "-y" ]]; then
      echo "Newer git available. Upgrading because you provided '-y' to proceed."
         if [[ "$OS" = "RCE" ]]; then
           upgradegitRHF;
         elif [[ "$OS" = "Deb" ]]; then
           upgradegitDeb;
         else
		 echo -e "Uncertain OS. Expecting RHEL 7/8, Fedora 21+ or Debian 8; Exiting."
           exit 1
         fi
   else
      echo "Something other than 'equal or not-equal' version comparison went wrong; Exiting."
      exit 1
   fi

fi

#END
