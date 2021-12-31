#!/bin/bash

# disable firewalld
systemctl stop firewalld
systemctl disable firewalld
systemctl mask firewalld

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