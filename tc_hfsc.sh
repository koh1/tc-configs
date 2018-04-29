#!/bin/sh

DEV=gtp0

if [ "$1" = "hfsc" ] ; then
    /sbin/tc qdisc add dev $DEV root handle 1: hfsc default 22
    #/sbin/tc qdisc add dev $DEV root handle 1: hfsc

    /sbin/tc class add dev $DEV parent 1: classid 1:1 hfsc sc rate 16mbit ul rate 16mbit
    /sbin/tc class add dev $DEV parent 1:1 classid 1:10 hfsc sc rate 8mbit 
    /sbin/tc class add dev $DEV parent 1:1 classid 1:20 hfsc sc rate 8mbit ul rate 8mbit

    # 10 users sends 1 full size frame every 10ms.
    /sbin/tc class add dev $DEV parent 1:10 classid 1:11 hfsc sc m1 12mbit d 7ms m2 4mbit
    /sbin/tc class add dev $DEV parent 1:10 classid 1:12 hfsc sc m2 4mbit
    # 5 users sends 1 full size frame every 10ms.
    /sbin/tc class add dev $DEV parent 1:20 classid 1:21 hfsc sc m1 6mbit d 7ms m2 4mbit
    /sbin/tc class add dev $DEV parent 1:20 classid 1:22 hfsc sc m2 4mbit

    /sbin/tc filter add dev $DEV protocol ip parent 1: prio 10 handle 1 fw flowid 1:11
    /sbin/tc filter add dev $DEV protocol ip parent 1: prio 2 handle 2 fw flowid 1:12
elif [ "$1" = "htb" ] ; then
    /sbin/tc qdisc add dev $DEV root handle 1: htb default 22
    /sbin/tc class add dev $DEV parent 1: classid 1:1 htb rate 16Mbit ceil 16Mbit
    /sbin/tc class add dev $DEV parent 1:1 classid 1:10 htb rate 8mbit 
    /sbin/tc class add dev $DEV parent 1:1 classid 1:20 htb rate 8mbit ceil 8mbit

    /sbin/tc class add dev $DEV parent 1:10 classid 1:11 htb 4Mbit ceil 4Mbit
    /sbin/tc class add dev $DEV parent 1:10 classid 1:12 htb 4Mbit ceil 4Mbit

    /sbin/tc class add dev $DEV parent 1:20 classid 1:21 htb 4Mbit ceil 4Mbit
    /sbin/tc class add dev $DEV parent 1:20 classid 1:22 htb 4Mbit ceil 4Mbit

    /sbin/tc filter add dev $DEV protocol ip parent 1: prio 10 handle 1 fw flowid 1:11
    /sbin/tc filter add dev $DEV protocol ip parent 1: prio 2 handle 2 fw flowid 1:12
    
elif [ "$1" = "del" ] ; then
    /sbin/tc qdisc del dev $DEV root
fi

    
#tc qdisc add dev eth0 root handle 1: hfsc
#tc class add dev eth0 parent 1: classid 1:1 hfsc sc rate 1000kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:1 classid 1:10 hfsc sc rate 500kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:1 classid 1:20 hfsc sc rate 500kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:10 classid 1:11 hfsc sc umax 1500b dmax 53ms rate 400kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:10 classid 1:12 hfsc sc umax 1500b dmax 30ms rate 100kbit ul rate 1000kbit
