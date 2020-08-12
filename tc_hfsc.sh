#!/bin/sh

DEV=$1

#/sbin/ifconfig $DEV txqueuelen 1000

if [ "$2" = "hfsc" ] ; then
    /sbin/tc qdisc add dev $DEV root handle 1: hfsc default 20
    #/sbin/tc qdisc add dev $DEV root handle 1: hfsc

    /sbin/tc class add dev $DEV parent 1: classid 1:1 hfsc sc m2 90mbit ul m2 90mbit
    /sbin/tc class add dev $DEV parent 1:1 classid 1:10 hfsc sc m2 25mbit ul m2 90mbit
    /sbin/tc class add dev $DEV parent 1:1 classid 1:20 hfsc sc m2 65mbit ul m2 90mbit

    # 10 users sends 1 full size frame every 10ms.
    /sbin/tc class add dev $DEV parent 1:10 classid 1:11 hfsc sc m1 1mbit d 10ms m2 2mkbit    
    /sbin/tc class add dev $DEV parent 1:10 classid 1:12 hfsc sc m2 23mbit ul m2 25mbit

    # 5 users sends 1 full size frame every 10ms.
#    /sbin/tc class add dev $DEV parent 1:20 classid 1:21 hfsc sc m1 6mbit d 7ms m2 4mbit
    #    /sbin/tc class add dev $DEV parent 1:20 classid 1:22 hfsc sc rate 4mbit ul rate 4mbit

    /sbin/iptables -t mangle -A PREROUTING -p tcp -s 192.168.147.222 --sport 5000 -j MARK --set-mark 1
    /sbin/iptables -t mangle -A PREROUTING -p tcp -d 192.168.147.222 --dport 5000 -j MARK --set-mark 1
    /sbin/tc filter add dev $DEV protocol ip parent 1:10 prio 1 handle 1 fw flowid 1:11
    
#    /sbin/tc filter add dev $DEV protocol ip parent 1: prio 2 handle 2 fw flowid 1:12

elif [ "$2" = "htb" ] ; then
    /sbin/tc qdisc add dev $DEV root handle 1: htb default 20
    /sbin/tc class add dev $DEV parent 1: classid 1:1 htb rate 90Mbit ceil 90Mbit
    /sbin/tc class add dev $DEV parent 1:1 classid 1:10 htb rate 25mbit 
    /sbin/tc class add dev $DEV parent 1:1 classid 1:20 htb rate 65mbit ceil 90mbit

    /sbin/tc class add dev $DEV parent 1:10 classid 1:11 htb rate 2mbit
    /sbin/tc class add dev $DEV parent 1:10 classid 1:12 htb rate 23kbit ceil 25mbit

#    /sbin/tc class add dev $DEV parent 1:20 classid 1:21 htb rate 4mbit ceil 4mbit
    #    /sbin/tc class add dev $DEV parent 1:20 classid 1:22 htb rate 4mbit ceil 4mbit
    /sbin/iptables -t mangle -A PREROUTING -p tcp -s 192.168.147.222 --sport 5000 -j MARK --mark 1
    /sbin/iptables -t mangle -A PREROUTING -p tcp -d 192.168.147.222 --dport 5000 -j MARK --mark 1
    /sbin/tc filter add dev $DEV protocol ip parent 1: prio 1 handle 1 fw flowid 1:11
#    /sbin/tc filter add dev $DEV protocol ip parent 1: prio 2 handle 2 fw flowid 1:12
    
elif [ "$2" = "del" ] ; then
    /sbin/tc qdisc del dev $DEV root
    /sbin/iptables -t mangle -F
fi

    
#tc qdisc add dev eth0 root handle 1: hfsc
#tc class add dev eth0 parent 1: classid 1:1 hfsc sc rate 1000kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:1 classid 1:10 hfsc sc rate 500kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:1 classid 1:20 hfsc sc rate 500kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:10 classid 1:11 hfsc sc umax 1500b dmax 53ms rate 400kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:10 classid 1:12 hfsc sc umax 1500b dmax 30ms rate 100kbit ul rate 1000kbit
