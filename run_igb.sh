#!/bin/bash
# Simple script to run igb_avb

if [ "$#" -eq "0" ]; then 
    echo "please enter network interface name as parameter. For example:"
    echo "sudo ./run_igb.sh eth1"
    exit -1
fi

export INTERFACE=$1

rmmod igb
modprobe i2c_algo_bit
modprobe dca
modprobe ptp

insmod lib/igb_avb/kmod/igb_avb.ko 

ethtool -i $INTERFACE

sleep 1
ifconfig $INTERFACE down
echo 0 > /sys/class/net/$INTERFACE/queues/tx-0/xps_cpus
echo 0 > /sys/class/net/$INTERFACE/queues/tx-1/xps_cpus
echo f > /sys/class/net/$INTERFACE/queues/tx-2/xps_cpus
echo f > /sys/class/net/$INTERFACE/queues/tx-3/xps_cpus

# for production use non promiscous mode
ifconfig $INTERFACE up
# using Promiscuous Mode in development
# ifconfig $INTERFACE up promisc
