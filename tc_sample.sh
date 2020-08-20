#!/bin/bash

#DEV='enx0022cfedac8e'
#DEV='enp7s0'
#DEV='enp7s0.146'
DEV='eth0'
#DEV='eth1.146'

sudo /sbin/tc qdisc add dev $DEV root handle 1: hfsc default 20
sudo /sbin/tc class add dev $DEV parent 1: classid 1:1 hfsc sc m2 90mbit ul m2 90mbit
sudo /sbin/tc class add dev $DEV parent 1:1 classid 1:10 hfsc sc m2 25mbit ul m2 90mbit
sudo /sbin/tc class add dev $DEV parent 1:1 classid 1:20 hfsc sc m2 65mbit ul m2 90mbit

sudo /sbin/tc class add dev $DEV parent 1:10 classid 1:11 hfsc sc m1 1mbit d 10ms m2 2mbit    
sudo /sbin/tc class add dev $DEV parent 1:10 classid 1:12 hfsc sc m2 23mbit ul m2 25mbit

sudo /sbin/iptables -t mangle -A PREROUTING -p tcp -s 192.168.147.222 --sport 5000 -j MARK --set-mark 1
sudo /sbin/iptables -t mangle -A PREROUTING -p tcp -d 192.168.147.222 --dport 5000 -j MARK --set-mark 1
sudo /sbin/iptables -t mangle -A PREROUTING -p tcp -s 192.168.147.222 --sport 5000 -j TOS --set-tos 16
sudo /sbin/iptables -t mangle -A PREROUTING -p tcp -d 192.168.147.222 --dport 5000 -j TOS --set-tos 16

sudo /sbin/tc filter add dev $DEV protocol ip parent 1: prio 1 handle 1 fw flowid 1:11

