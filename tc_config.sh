#!/bin/bash

DEV=$1
echo $DEV

#/sbin/ifconfig $DEV txqueuelen 1000

if [ "$2" = "hfsc" ] ; then
    sudo /sbin/tc qdisc add dev $DEV root handle 1: hfsc default 20

    #    sudo /sbin/tc class add dev $DEV parent 1: classid 1:1 hfsc sc m2 90mbit ul m2 90mbit
    #sudo /sbin/tc class add dev $DEV parent 1: classid 1:1 hfsc ls m2 90mbit ul m2 90mbit
    sudo /sbin/tc class add dev $DEV parent 1: classid 1:1 hfsc sc rate 90mbit ul rate 90mbit    

    #    sudo /sbin/tc class add dev $DEV parent 1:1 classid 1:10 hfsc sc m1 10mbit d 5ms m2 90mbit
    #sudo /sbin/tc class add dev $DEV parent 1:1 classid 1:20 hfsc ls m2 80mbit ul m2 90mbit
    #sudo /sbin/tc class add dev $DEV parent 1:1 classid 1:10 hfsc rt m1 10mbit d 1ms m2 90mbit
    sudo /sbin/tc class add dev $DEV parent 1:1 classid 1:20 hfsc sc m2 85mbit ul m2 90mbit
    sudo /sbin/tc class add dev $DEV parent 1:1 classid 1:10 hfsc rt m1 5mbit d 1ms m2 90mbit

    # 10 users sends 1 full size frame every 10ms.
#    sudo /sbin/tc class add dev $DEV parent 1:10 classid 1:11 hfsc sc m1 5mbit d 10ms m2 10mbit    
#    sudo /sbin/tc class add dev $DEV parent 1:10 classid 1:12 hfsc sc m2 75mbit ul m2 80mbit

    sudo /sbin/tc filter add dev $DEV protocol ip parent 1: prio 1 handle 1 fw flowid 1:10

elif [ "$2" = "hfsc1g" ] ; then
    sudo /sbin/tc qdisc add dev $DEV root handle 1: hfsc default 20
    sudo /sbin/tc class add dev $DEV parent 1: classid 1:1 hfsc sc rate 1000mbit ul rate 1000mbit    
    sudo /sbin/tc class add dev $DEV parent 1:1 classid 1:20 hfsc sc m2 995mbit ul m2 1000mbit
    sudo /sbin/tc class add dev $DEV parent 1:1 classid 1:10 hfsc rt m1 5mbit d 1ms m2 1000mbit
    sudo /sbin/tc filter add dev $DEV protocol ip parent 1: prio 1 handle 1 fw flowid 1:10

elif [ "$2" = "pfifo" ] ; then
    sudo /sbin/tc qdisc add dev $DEV root pfifo_fast

elif [ "$2" = "tbf" ] ; then
    sudo /sbin/tc qdisc add dev $DEV root tbf burst 4kb limit 45kb rate 90mbit

elif [ "$2" = "htb" ] ; then

    sudo /sbin/tc qdisc add dev $DEV root handle 1: htb default 20
    sudo /sbin/tc class add dev $DEV parent 1: classid 1:1 htb rate 90Mbit ceil 90Mbit
    sudo /sbin/tc class add dev $DEV parent 1:1 classid 1:10 htb rate 5mbit  ceil 90mbit
    sudo /sbin/tc class add dev $DEV parent 1:1 classid 1:20 htb rate 85mbit ceil 90mbit

    sudo /sbin/tc filter add dev $DEV protocol ip parent 1: prio 1 handle 1 fw flowid 1:10
elif [ "$2" = "htb0" ] ; then

    sudo /sbin/tc qdisc add dev $DEV root handle 1: htb default 1
    sudo /sbin/tc class add dev $DEV parent 1: classid 1:1 htb rate 90Mbit ceil 90Mbit

elif [ "$2" = "htbfqcodel90m" ] ; then

    sudo /sbin/tc qdisc add dev $DEV root handle 1: htb default 1
    sudo /sbin/tc class add dev $DEV parent 1: classid 1:1 htb rate 90Mbit ceil 90Mbit
    sudo /sbin/tc qdisc add dev $DEV parent 1:1 fq_codel 

elif [ "$2" = "htbfqcodel1g" ] ; then
    sudo /sbin/tc qdisc add dev $DEV root handle 1: htb default 1
    sudo /sbin/tc class add dev $DEV parent 1: classid 1:1 htb rate 1000Mbit ceil 1000Mbit
    sudo /sbin/tc qdisc add dev $DEV parent 1:1 fq_codel 

elif [ "$2" = "setiptables" ] ; then
    echo "set iptables"
    sudo /sbin/iptables -t mangle -A PREROUTING -p tcp -s 192.168.146.222 --sport 5000 -j MARK --set-mark 1
    sudo /sbin/iptables -t mangle -A PREROUTING -p tcp -d 192.168.146.222 --dport 5000 -j MARK --set-mark 1
    sudo /sbin/iptables -t mangle -A PREROUTING -p tcp -s 192.168.148.15 --sport 15555 -j MARK --set-mark 1
    sudo /sbin/iptables -t mangle -A PREROUTING -p tcp -d 192.168.148.15 --dport 15555 -j MARK --set-mark 1
    
elif [ "$2" = "deltc" ] ; then
    sudo /sbin/tc qdisc del dev $DEV root
#    sleep 1
#    sudo /sbin/tc filter del dev $DEV root
elif [ "$2" = "deliptables" ] ; then
    sudo /sbin/iptables -t mangle -F
fi

    
#tc qdisc add dev eth0 root handle 1: hfsc
#tc class add dev eth0 parent 1: classid 1:1 hfsc sc rate 1000kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:1 classid 1:10 hfsc sc rate 500kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:1 classid 1:20 hfsc sc rate 500kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:10 classid 1:11 hfsc sc umax 1500b dmax 53ms rate 400kbit ul rate 1000kbit
#tc class add dev eth0 parent 1:10 classid 1:12 hfsc sc umax 1500b dmax 30ms rate 100kbit ul rate 1000kbit
