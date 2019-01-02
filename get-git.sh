#!/bin/bash
# get-git.sh -- by funixz -- https://github.com/funixz
# Retrieves latest version of git and installs from source if you allow it.
# - Debian requires these installed: libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev build-essential autoconf
# - RHEL/ Centos requires these installed: gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel gcc autoconf
# - built on Debian 8 & CentOS 7
# - run with sudo/root
# - try to make sure there's no prior git files in /tmp before running.
##################################################################################

#global variables

cgitver="v$(/usr/local/bin/git --version|cut -d ' ' -f 3)"
wgit=$(which git)
#cgitver="v2.16.0-rc1" #for testing
#latest=$(curl https://github.com/git/git/releases -s | grep archive | grep '.tar.gz' | cut -d \" -f 2 | head -n 1 | cut -d \/ -f 5 |sed 's/.tar.gz//')
latest=$(curl https://github.com/git/git/releases -s | grep archive | grep '.tar.gz' | cut -d \" -f 4 | head -n 1 | cut -d \/ -f 5 |sed 's/.tar.gz//')
wdir=$(curl https://github.com/git/git/releases -s | grep archive | grep '.tar.gz' | cut -d \" -f 4 | head -n 1 | cut -d \/ -f 5 |sed 's/v//' |sed 's/.tar.gz//')
OS=""

#functions

s2() {
sleep 1s
}

#uninstallgit() {
# up next
#;}

gitreport() {
	cgitver="v$(/usr/local/bin/git --version|cut -d ' ' -f 3)"
	wgit="/usr/local$(which git)"
	echo -e "\nCurrent installed Git version is now $cgitver, found at $wgit .\n"
}

upgradegitDeb() {
echo -e "\nUpgrading Git..."
echo "Going from -- $cgitver -- to -- $latest --. \n"
newlink="https://github.com/git/git/archive/$latest.tar.gz"
#-----
echo "pulling from $newlink"
cd /tmp && wget -q --show-progress $newlink
s2;
cd /tmp && tar -xzf $(curl https://github.com/git/git/releases -s | grep archive | grep '.tar.gz' | cut -d \" -f 4 | head -n 1 | cut -d \/ -f 5)
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
echo -e "\nUpgrading Git..."
echo -e "Going from -- $cgitver -- to -- $latest --. \n"
newlink="https://github.com/git/git/archive/$latest.tar.gz"
#-----
echo "pulling from $newlink"
cd /tmp && wget -q --progress=bar:force $newlink
s2;
cd /tmp && tar -xzf $(curl https://github.com/git/git/releases -s | grep archive | grep '.tar.gz' | cut -d \" -f 4 | head -n 1 | cut -d \/ -f 5)
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
fi

# help parameter handling
if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ -n "$1" ]; then
  echo "--------------------------------------------------------------------------------"
  echo "get-git.sh -- by funixz -- https://github.com/funixz"
  echo "Retrieves latest version of git and installs from source if you allow it."
  echo "- run with sudo/root"
  echo "- make sure there's no prior git related files/folders in /tmp before running."
  echo "- currently accepts no CLI parameters, except '-h' or '--help'"
  echo -e "--------------------------------------------------------------------------------\n"
else

 echo "Current installed Git version is $cgitver ."
 echo -e "Latest Git on github.com is $latest \n"

 if [ "$cgitver" == "$latest" ]; then
    echo "Current Git matches latest available. Exiting."
    exit 0
 elif [ "$cgitver" != "$latest" ]; then
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
 else
    echo "Something other than 'equal or not-equal' version comparison went wrong. Exiting."
    exit 1
 fi

fi

#END
