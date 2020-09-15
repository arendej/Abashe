# Abashe
*My Bash Scripts*

 * [get-git.sh](https://github.com/funixz/Abashe/blob/master/get-git.sh)
   - Retrieves latest version of git and installs from source if you allow it.
   - built on Debian
   - runs (tested) on CentOS7 or RHEL7 or Debian 8

 * [setup-teamd-lacp.sh](https://github.com/funixz/Abashe/blob/master/setup-teamd-lacp.sh)
   - dumb script that sets up an LACP teamed set of ethernet interfaces, assuming the switch ports are setup already.
   - tested and built on CentOS8
   - Uses nmcli, **teamd**, networkmanager

 * [setup-bond-lacp.sh](https://github.com/funixz/Abashe/blob/master/setup-bond-lacp.sh)
   - dumb script that sets up an LACP bonded set of ethernet interfaces, assuming the switch ports are setup already.
   - tested and built on CentOS8
   - Uses nmcli, **bond** kernel driver, networkmanager
