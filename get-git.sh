#!/bin/bash
# get-git.sh -- by funixz -- https://github.com/funixz
# Retrieves latest version of git and installs from source if you allow it.
# - built on Debian
# - run with sudo/root
# - make sure there's no prior git files in /tmp before running.
##################################################################################

#global variables

cgitver=v$(git --version|cut -d ' ' -f 3)
#cgitver="v2.16.0-rc1" #for testing
latest=$(curl https://github.com/git/git/releases -s | grep archive | grep '.tar.gz' | cut -d \" -f 2 | head -n 1 | cut -d \/ -f 5 |sed 's/.tar.gz//')
wdir=$(curl https://github.com/git/git/releases -s | grep archive | grep '.tar.gz' | cut -d \" -f 2 | head -n 1 | cut -d \/ -f 5 |sed 's/v//' |sed 's/.tar.gz//')

#functions

s2() {
sleep 2s
}

#uninstallgit() {
# up next
#;}

upgradegit() {
echo ""; echo "Upgrading Git..."
echo "Going from -- $cgitver -- to -- $latest --. "; echo ""
newlink="https://github.com/git/git/archive/$latest.tar.gz"
#-----
echo "pulling from $newlink"
cd /tmp && wget -q --show-progress $newlink
s2;
cd /tmp && tar -xzf $(curl https://github.com/git/git/releases -s | grep archive | grep '.tar.gz' | cut -d \" -f 2 | head -n 1 | cut -d \/ -f 5)
s2
cd /tmp/git-$wdir && make configure >> /tmp/git-from-source.log 2>&1
s2
cd /tmp/git-$wdir && ./configure
s2
cd /tmp/git-$wdir && make prefix=/usr/local all > /tmp/git-from-source.log 2>&1
s2
cd /tmp/git-$wdir && make prefix=/usr/local install > /tmp/git-from-source.log 2>&1
s2
which git
#-----

echo ""; echo "Done."; echo "Current installed Git version is now $cgitver ."; echo ""
}

#main

if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ -n "$1" ]; then
  echo "--------------------------------------------------------------------------------"
  echo "get-git.sh -- by funixz -- https://github.com/funixz"
  echo "Retrieves latest version of git and installs from source if you allow it."
  echo "- run with sudo/root"
  echo "- make sure there's no prior git related files/folders in /tmp before running."
  echo "- currently accepts no CLI parameters, except '-h' or '--help'"
  echo "--------------------------------------------------------------------------------"
  echo ""
else

 echo "Current installed Git version is $cgitver ."
 echo "Latest Git on github.com is $latest"; echo ""

 if [ "$cgitver" == "$latest" ]; then
    echo "Current Git matches latest available. Exiting."
    exit 0
 elif [ "$cgitver" != "$latest" ]; then
    echo "Newer git available. Upgrade? [y/n]:"
    read upg
    if [ "$upg" == "y" ] || [ "$upg" == "Y" ]; then
       upgradegit;
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
