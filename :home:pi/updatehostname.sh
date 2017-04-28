#!/bin/bash

newhostname=$1
if [ -z "$newhostname" ]
then
	echo "Usage: ./updatehisname.sh new_hostname"
	exit 1
fi

echo "Changing hostname to $newhostname"

echo "127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

#127.0.1.1      raspberrypi
127.0.1.1       $newhostname" > /etc/hosts

echo $newhostname > /etc/hostname

/etc/init.d/hostname.sh

reboot
