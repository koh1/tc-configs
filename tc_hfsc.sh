#!/bin/sh

DEV=enp3s0

if [ "$1" = "init" ] ; then
    /sbin/tc qdisc add dev $DEV root handle 1: hfsc default 1:11
    
elif [ "$1" = "config" ] ; then
    /sbin/tc class add dev $DEV parent 1: classid 1:1 hfsc sc rate 1000kbit ul rate 1000kbit
    /sbin/tc class add dev $DEV parent 1:1 classid 1:10 hfsc sc rate 500kbit ul rate 1000kbit
    /sbin/tc class add dev $DEV parent 1:1 classid 1:20 hfsc sc rate 500kbit ul rate 1000kbit
    /sbin/tc class add dev $DEV parent 1:10 classid 1:11 hfsc sc umax 1500b dmax 53ms rate 400kbit ul rate 1000kbit
    /sbin/tc class add dev $DEV parent 1:10 classid 1:12 hfsc sc umax 1500b dmax 30ms rate 100kbit ul rate 1000kbit
    
elif [ "$1" = "purge" ] ; then
    /sbin/tc qdisc del dev $DEV root
fi

    
#tc qdisc add dev eth0 root handle 1: hfsc
#tc class add dev eth0 parent 1: classid 1:1 hfsc sc rate 1000kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:1 classid 1:10 hfsc sc rate 500kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:1 classid 1:20 hfsc sc rate 500kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:10 classid 1:11 hfsc sc umax 1500b dmax 53ms rate 400kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:10 classid 1:12 hfsc sc umax 1500b dmax 30ms rate 100kbit ul rate 1000kbit
