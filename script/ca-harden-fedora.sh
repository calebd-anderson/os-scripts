#!/bin/bash
# fedora web/mail script by Caleb Anderson (www.calebdanderson.dev)

# backup original iptables
iptables-save > original-iptables.out

# disable firewalld
systemctl stop firewalld
systemctl disable firewalld

# clear all iptables
iptables -X
iptables -F
# set default deny
iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP

# setup my services
iptables -A INPUT -p tcp -m multiport --dports 25,80,110,143 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sports 25,80,110,143 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p udp -m multiport --dports 53,123,389 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 389,443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# disable ipv6
echo 'net.ipv6.conf.all.disable_ipv6=1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6=1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.lo.disable_ipv6=1' >> /etc/sysctl.conf
sysctl -p

# zip / quarantine redteam www
tar -czf ~/quarantine_www.tar.gz /var/www/html
rm -rf /var/www/html/*

# add redirect to roundcube
echo "<!DOCTYPE html>
<html lang=\"en-US\">
  <meta charset=\"utf-8\">
  <title>Redirecting&hellip;</title>
  <link rel=\"canonical\" href=\"/roundcubemail\">
  <script>location=\"/roundcubemail\"</script>
  <meta http-equiv=\"refresh\" content=\"0; url=/roundcubemail\">
  <meta name=\"robots\" content=\"noindex\">
  <h1>Redirecting&hellip;</h1>
  <a href=\"/roundcubemail\">Click here if you are not redirected.</a>
</html>" > /var/www/html/index.html

# quarantine redteam iptables
gzip /etc/sysconfig/iptables-config
mv /etc/sysconfig/iptables-config.gz ~/quarantine_iptables.gz
# replace good iptables-config
echo "# Load additional iptables modules (nat helpers)
#   Default: -none-
# Space separated list of nat helpers (e.g. 'ip_nat_ftp ip_nat_irc'), which
# are loaded after the firewall rules are applied. Options for the helpers are
# stored in /etc/modprobe.conf.
IPTABLES_MODULES=""

# Unload modules on restart and stop
#   Value: yes|no,  default: yes
# This option has to be 'yes' to get to a sane state for a firewall
# restart or stop. Only set to 'no' if there are problems unloading netfilter
# modules.
IPTABLES_MODULES_UNLOAD=\"yes\"

# Save current firewall rules on stop.
#   Value: yes|no,  default: no
# Saves all firewall rules to /etc/sysconfig/iptables if firewall gets stopped
# (e.g. on system shutdown).
IPTABLES_SAVE_ON_STOP=\"no\"

# Save current firewall rules on restart.
#   Value: yes|no,  default: no
# Saves all firewall rules to /etc/sysconfig/iptables if firewall gets
# restarted.
IPTABLES_SAVE_ON_RESTART=\"no\"

# Save (and restore) rule and chain counter.
#   Value: yes|no,  default: no
# Save counters for rules and chains to /etc/sysconfig/iptables if
# 'service iptables save' is called or on stop or restart if SAVE_ON_STOP or
# SAVE_ON_RESTART is enabled.
IPTABLES_SAVE_COUNTER=\"no\"

# Numeric status output
#   Value: yes|no,  default: yes
# Print IP addresses and port numbers in numeric format in the status output.
IPTABLES_STATUS_NUMERIC=\"yes\"

# Verbose status output
#   Value: yes|no,  default: yes
# Print info about the number of packets and bytes plus the \"input-\" and
# \"outputdevice\" in the status output.
IPTABLES_STATUS_VERBOSE=\"no\"

# Status output with numbered lines
#   Value: yes|no,  default: yes
# Print a counter/number for every rule in the status output.
IPTABLES_STATUS_LINENUMBERS=\"yes\"" > /etc/sysconfig/iptables-config

# audit system accounts with logins
awk -F: '($1!="root" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"') {print $1}' /etc/passwd | xargs -I '{}' passwd -S '{}' | awk '($2!="L" && $2!="LK") {print $1}' > audit_system_users.txt
echo "usable system accounts in \"audit_system_users.txt\"\n"

# chroot postfix
CP="cp -p"
cond_copy() {
  # find files as per pattern in $1
  # if any, copy to directory $2
  dir=`dirname "$1"`
  pat=`basename "$1"`
  lr=`find "$dir" -maxdepth 1 -name "$pat"`
  if test ! -d "$2" ; then exit 1 ; fi
  if test "x$lr" != "x" ; then $CP $1 "$2" ; fi
} 
set -e
umask 022
POSTFIX_DIR=${POSTFIX_DIR-/var/spool/postfix}
cd ${POSTFIX_DIR}
mkdir -p etc lib usr/lib/zoneinfo
test -d /lib64 && mkdir -p lib64
# find localtime (SuSE 5.3 does not have /etc/localtime)
lt=/etc/localtime
if test ! -f $lt ; then lt=/usr/lib/zoneinfo/localtime ; fi
if test ! -f $lt ; then lt=/usr/share/zoneinfo/localtime ; fi
if test ! -f $lt ; then echo "cannot find localtime" ; exit 1 ; fi
rm -f etc/localtime
# copy localtime and some other system files into the chroot's etc
$CP -f $lt /etc/services /etc/resolv.conf /etc/nsswitch.conf etc
$CP -f /etc/host.conf /etc/hosts /etc/passwd etc
ln -s -f /etc/localtime usr/lib/zoneinfo
# copy required libraries into the chroot
cond_copy '/lib/libnss_*.so*' lib
cond_copy '/lib/libresolv.so*' lib
cond_copy '/lib/libdb.so*' lib
if test -d /lib64; then
  cond_copy '/lib64/libnss_*.so*' lib64
  cond_copy '/lib64/libresolv.so*' lib64
  cond_copy '/lib64/libdb.so*' lib64
fi
postfix reload
