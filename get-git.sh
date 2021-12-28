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

cgitver="v$(/usr/local/bin/git --version|cut -d ' ' -f 3)"
loccurgitver="v$($(which git) --version|cut -d ' ' -f 3)"
wgit=$(which git)
#cgitver="v2.16.0-rc1" #for testing
#old# latest=$(curl https://github.com/git/git/releases -s | grep archive | grep '.tar.gz' | cut -d \" -f 4 | head -n 1 | cut -d \/ -f 5 |sed 's/.tar.gz//')
latest=$(curl https://github.com/git/git/tags -s| grep [0-9].tar.gz| cut -d \" -f 4|head -n 1 | cut -d \/ -f 7 | sed 's/.tar.gz//')
wdir=$(curl https://github.com/git/git/tags -s| grep [0-9].tar.gz| cut -d \" -f 4|head -n 1 | cut -d \/ -f 7  |sed 's/v//' |sed 's/.tar.gz//')
OS=""

#functions

s2() {
sleep 1s
}

#uninstallgit() {
# up next
#;}

gitreport() {
	loccurgitver="v$($(which git) --version|cut -d ' ' -f 3)"
	cgitver="v$(/usr/local/bin/git --version|cut -d ' ' -f 3)"
	wgit="$(which git)"
	echo -e "\nNon-stock Git version is $cgitver, found at /usr/local/bin/git ."
	echo -e "Stock Git version is $loccurgitver, found at $wgit ."
	echo -e "\nYou may opt to use a specific one and remove the other.\n"
}

upgradegitDeb() {
echo -e "\nUpgrading Git on Debian..."
echo "Going from -- $cgitver or $loccurgitver -- to -- $latest --. \n"
newlink="https://github.com/git/git/archive/refs/tags/$latest.tar.gz"
#-----
echo "pulling from $newlink"
cd /tmp && wget --show-progress $newlink
s2
cd /tmp && tar -xzf $(curl https://github.com/git/git/tags -s| grep [0-9].tar.gz | cut -d \" -f 4 | head -n 1 | cut -d \/ -f 7)
s2
cd /tmp/git-$wdir && make --silent configure >> /tmp/git-from-source.log 2>&1
s2
cd /tmp/git-$wdir && ./configure
s2
cd /tmp/git-$wdir && make --silent prefix=/usr/local all > /tmp/git-from-source.log 2>&1
s2
cd /tmp/git-$wdir && make --silent prefix=/usr/local install > /tmp/git-from-source.log 2>&1
s2
#-----
gitreport;
}

upgradegitCE() {
echo -e "\nInstalling dependencies.."
yum -q groupinstall -y "Development Tools"
yum -q install -y wget gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel gcc autoconf
echo -e "\nUpgrading Git on RHEL/Fedora ..."
echo -e "Going from -- $cgitver or $loccurgitver -- to -- $latest --. \n"
newlink="https://github.com/git/git/archive/refs/tags/$latest.tar.gz"
#-----
echo "pulling from $newlink"
cd /tmp && wget --progress=bar:force $newlink
s2;
cd /tmp && tar -xzf $(curl https://github.com/git/git/tags -s| grep [0-9].tar.gz | cut -d \" -f 4 | head -n 1 | cut -d \/ -f 7)
s2
cd /tmp/git-$wdir && make --silent configure >> /tmp/git-from-source.log 2>&1
s2
cd /tmp/git-$wdir && ./configure --prefix=/usr/local
s2
cd /tmp/git-$wdir && make --silent install > /tmp/git-from-source.log 2>&1
s2
#-----
gitreport;
}

#main

# discover Debian or CentOS
if [[ $(cat /etc/debian-version |grep "8.") ]]; then
  OS="Deb"
elif [[ $(cat /etc/redhat-release |grep " 7.") ]]; then
  OS="RCE"
elif [[ $(cat /etc/redhat-release |grep " 8.") ]]; then
  OS="RCE"
elif (( $(cat /etc/redhat-release |grep Fedora |awk '{print$3}') > 21 )); then
  OS="RCE"
fi

# help parameter handling - if asking for help or , then show it.
if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ -n "$1" ]; then
   echo -e "--------------------------------------------------------------------------------"
   echo " get-git.sh -- by arendej -- https://github.com/arendej"
   echo -e " Retrieves latest version of git from GitHub  and installs from source if you\nallow it."
   echo "  - run with sudo/root"
   echo "  - make sure there's no prior git related files/folders in /tmp before running."
   echo -e "  - currently accepts '-h' or '--help' for help and '-y' to upgrade\nwithout prompt"
   echo -e "--------------------------------------------------------------------------------\n"
else

   echo "Current non-stock Git version is $cgitver (if installed)."
   echo "Current stock Git version is $loccurgitver (if installed)."
   echo -e "Latest Git on github.com is $latest \n"

   if [[ "$cgitver" == "$latest" && "$1" != "-y" ]]; then
      echo "Current Git matches latest available. Exiting."
      exit 0
   elif [[ "$cgitver" != "$latest" && "$1" != "-y" ]]; then
      echo "Newer git available. Upgrade? [y/n]:"
      read upg
      if [ "$upg" == "y" ] || [ "$upg" == "Y" ]; then
         if [ "$OS" == "RCE" ]; then
           upgradegitCE;
         elif [ "$OS" == "Deb" ]; then
           upgradegitDeb;
         else
           echo "Uncertain OS. Expecting RHEL 7/ CentOS 7 or Debian 8. Exiting."
           exit 1
         fi
      else
         echo "No upgrade to take place. Exiting."
         exit 0
      fi
   elif [[ "$cgitver" != "$latest" && "$1" == "-y" ]]; then
      echo "Newer git available. Upgrading because you provided '-y' to proceed"
         if [ "$OS" == "RCE" ]; then
           upgradegitCE;
         elif [ "$OS" == "Deb" ]; then
           upgradegitDeb;
         else
		 echo -e "Uncertain OS. Expecting RHEL 7/8 (or derived) or Fedora or Debian 8. Exiting."
           exit 1
         fi
   else
      echo "Something other than 'equal or not-equal' version comparison went wrong. Exiting."
      exit 1
   fi

fi

#END
