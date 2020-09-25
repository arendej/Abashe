#!/bin/bash
#
# Setup bond0 via nmcli.
# This needs to be run on the system itself unless you've a third interface to SSH in with.
# This sets up two interfaces in LACP mode, assuming the switch is already prepared for it.
# Tested with a Procurve 1800-24g switch with LACP enabled on the ports (NOT Trunking).
# DO CHECK THE WHOLE SCRIPT before using, ensuring values are appropriate/
# Assumes to be run with root privileges for package install and network changes.
# Assumes the intended interfaces and names are nonexistent.
##

ETH1="enp2s0f0"       # interface 1
ETH2="enp2s0f1"       # interface 2
BOND="bond0"          # desired name for the bond interface
TYPE="4"           # the mode for the bond interface (this script assumed for lacp)
SYSIP="x.x.x.x"  # ip of the server
MASK="24"        # network mask (eg: 24 == 255.255.255.0)
GW="x.x.x.x"     # your gateway IP
DNSIP="x.x.x.x"  # your DNS server
SDNS="x.xyz.x"   # your DNS domain

# first, drop the ethernet connections we want to use. This is what the docs didn't tell us.

ip link set dev ${ETH1} down
ip link set dev ${ETH2} down

# now create the bond interface
nmcli connection add type bond con-name ${BOND} ifname ${BOND} bond.options mode=${TYPE},xmit_hash_policy=2

# add the ethernet ports
nmcli connection add type ethernet slave-type bond con-name ${BOND}-port1 ifname ${ETH1} master ${BOND}
nmcli connection add type ethernet slave-type bond con-name ${BOND}-port2 ifname ${ETH2} master ${BOND}

# setup the addressing for the team
nmcli connection modify ${BOND} ipv4.addresses ${SYSIP}/${MASK} # ip/netmask
nmcli connection modify ${BOND} ipv4.gateway ${GW}  # your gateway IP
nmcli connection modify ${BOND} ipv4.dns ${DNSIP}  # your DNS server
nmcli connection modify ${BOND} ipv4.dns-search ${SDNS}  # your dns domain
nmcli connection modify ${BOND} ipv4.method manual  # this is a static IP

# activate the team
nmcli connection up ${BOND}

# verify
nmcli device && nmcli connection show

# Set to autoconnect the joined interfaces
nmcli connection modify ${BOND} connection.autoconnect-slaves 1

# reactivate the team
nmcli connection up ${BOND}

# show status
cat /proc/net/bonding/${BOND}
