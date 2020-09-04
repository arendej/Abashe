#!/bin/bash
#
# Setup team0 via nmcli.
# This needs to be run on the system itself unless you've a third interface to SSH in with.
# This sets up two interfaces in LACP mode, assuming the switch is already prepared for it.
# Tested with a Procurve 1800-24g switch with LACP enabled on the ports (NOT Trunking).
# DO CHECK THE WHOLE SCRIPT before using, ensuring values are appropriate/
# Assumes to be run with root privileges for package install and network changes.
# Assumes the intended interfaces and names are nonexistent.
##

ETH1="enp2s0f0"       # interface 1
ETH2="enp2s0f1"       # interface 2
TEAM="team0"          # desired name for the teamd interface
TYPE="lacp"           # the mode for the teamd interface (this script assumed for lacp)
SYSIP="x.x.x.x"  # ip of the server
MASK="24"        # network mask (eg: 24 == 255.255.255.0)
GW="x.x.x.x"     # your gateway IP
DNSIP="x.x.x.x"  # your DNS server
SDNS="x.xyz.x"   # your DNS domain


# install necessary packages
yum install teamd NetworkManager-team -y

# first, drop the ethernet connections we want to use. This is what the docs didn't tell us.

ip link set dev ${ETH1} down
ip link set dev ${ETH2} down

# now create the team interface
nmcli connection add type team con-name ${TEAM} ifname ${TEAM} team.runner ${TYPE}

# set the llink watcher
nmcli connection modify ${TEAM} team.link-watchers "name=ethtool"

# add the ethernet ports
nmcli connection add type ethernet slave-type team con-name ${TEAM}-port1 ifname ${ETH1} master ${TEAM}
nmcli connection add type ethernet slave-type team con-name ${TEAM}-port2 ifname ${ETH2} master ${TEAM}

# setup the addressing for the team
nmcli connection modify ${TEAM} ipv4.addresses ${SYSIP}/${MASK} # ip/netmask
nmcli connection modify ${TEAM} ipv4.gateway ${GW}  # your gateway IP
nmcli connection modify ${TEAM} ipv4.dns ${DNSIP}  # your DNS server
nmcli connection modify ${TEAM} ipv4.dns-search ${SDNS}  # your dns domain
nmcli connection modify ${TEAM} ipv4.method manual  # this is a static IP

# activate the team
nmcli connection up ${TEAM}

# verify
teamdctl ${TEAM} state
