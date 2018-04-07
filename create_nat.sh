#!/bin/bash
help_text="Create a simple NAT with iptables from interface 1 (internet) to interface 2\nUsage: sudo bash create_nat int1 int2\n"

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    printf "${help_text}"
    exit
fi

if [ "$#" -ne 2 ]
    then echo "Must have two arguments"
    printf "${help_text}"
    exit
fi

interfaces=$(ls /sys/class/net/ | tr " " "\n")
let val=0
for int in $interfaces
do
    if [ "$int" == "$1" ] || [ "$int" == "$2" ]
        then let "val++"
    fi
done

if [ "$val" -ne 2 ]
    then echo "Wrong interface(s)"
    exit
fi

sysctl net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o $1 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $2 -o $1 -j ACCEPT

echo "NAT established"
