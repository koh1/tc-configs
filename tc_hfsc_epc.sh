#!/bin/sh

DEV=gtp0

#/sbin/ifconfig $DEV txqueuelen 1000

if [ "$1" = "hfsc" ] ; then
    /sbin/tc qdisc add dev $DEV root handle 1: hfsc default 20
    #/sbin/tc qdisc add dev $DEV root handle 1: hfsc

    /sbin/tc class add dev $DEV parent 1: classid 1:1 hfsc sc m2 16mbit ul m2 16mbit
    /sbin/tc class add dev $DEV parent 1:1 classid 1:10 hfsc sc m2 8mbit
    /sbin/tc class add dev $DEV parent 1:1 classid 1:20 hfsc sc m2 8mbit ul m2 8mbit

    # 10 users sends 1 full size frame every 10ms.
    /sbin/tc class add dev $DEV parent 1:10 classid 1:11 hfsc sc m2 16mbit
    /sbin/tc class add dev $DEV parent 1:10 classid 1:12 hfsc sc m1 2400kbit d 2ms m2 1200kbit

    # 5 users sends 1 full size frame every 10ms.
    #    /sbin/tc class add dev $DEV parent 1:20 classid 1:21 hfsc sc m1 6mbit d 7ms m2 4mbit
    #    /sbin/tc class add dev $DEV parent 1:20 classid 1:22 hfsc sc rate 4mbit ul rate 4mbit

    /sbin/tc filter add dev $DEV protocol ip parent 1: prio 10 handle 1 fw flowid 1:12
    /sbin/tc filter add dev $DEV protocol ip parent 1: prio 2 handle 2 fw flowid 1:11
elif [ "$1" = "htb" ] ; then
    /sbin/tc qdisc add dev $DEV root handle 1: htb default 20
    /sbin/tc class add dev $DEV parent 1: classid 1:1 htb rate 16Mbit ceil 16Mbit
    /sbin/tc class add dev $DEV parent 1:1 classid 1:10 htb rate 8mbit
    /sbin/tc class add dev $DEV parent 1:1 classid 1:20 htb rate 8mbit ceil 8mbit

    /sbin/tc class add dev $DEV parent 1:10 classid 1:11 htb rate 6800kbit ceil 16mbit
    /sbin/tc class add dev $DEV parent 1:10 classid 1:12 htb rate 1200kbit

    #    /sbin/tc class add dev $DEV parent 1:20 classid 1:21 htb rate 4mbit ceil 4mbit
    #    /sbin/tc class add dev $DEV parent 1:20 classid 1:22 htb rate 4mbit ceil 4mbit

    /sbin/tc filter add dev $DEV protocol ip parent 1: prio 10 handle 1 fw flowid 1:12
    /sbin/tc filter add dev $DEV protocol ip parent 1: prio 2 handle 2 fw flowid 1:11

elif [ "$1" = "del" ] ; then
    /sbin/tc qdisc del dev $DEV root
fi

