#!/bin/bash

#Activer SSH si le fichier /media/usb0/SSHFLAG existe
#if [ -e /media/usb0/SSHFLAG ]; then
#  /usr/sbin/update-rc.d -f ssh enable
#  /bin/rm /media/usb0/SSHFLAG
#  tokenrestart="oui"
#fi

for part in /dev/sda*; do
  if [[ $part != "/dev/sda" && $part != "/dev/sda*" ]]
  then
    mkdir /media/usb
    mount $part /media/usb

    if [ -f /media/usb/TenboReader.cfg ]
    then
      cp /media/usb/TenboReader.cfg /home/pi/TenboReader.cfg
    fi

    umount $part
    rmdir /media/usb

  fi
done

if [ -f /home/pi/TenboReader.cfg ]
then
        . /home/pi/TenboReader.cfg
else
	echo "No config file available, no settings changed."
	exit 0
fi

echo "Hostname: $HOSTNAME"
if [ "$ReaderName" == $HOSTNAME ]
then
	echo "Hostname is up to date."
else
	echo "Hosname is not up to date, updating..."
	/home/pi/updatehostname.sh $ReaderName
fi

echo "Generating wpa_supplicant.conf"

if [ "$WifiMode" == "AccessPoint" ]
then
	SSID=""
fi

if [ $(cat /etc/wpa_supplicant/wpa_supplicant.conf | grep -Pzoc 'ssid="'$SSID'"\n	psk="'$RSA'"') == 1 ]
then
	echo "SSID settings up to date."
else
	echo "Updating SSID settings..."
	echo '' >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo 'network={' >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo '	ssid="'$SSID'"' >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo '	psk="'$RSA'"' >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo '}' >> /etc/wpa_supplicant/wpa_supplicant.conf
fi

echo "Generating dhcpcd.conf..."
cp /home/pi/config/dhcpcd.conf.sample /home/pi/config/dhcpcd.conf

if [ "$WifiMode" == "Client" ]
then
	if [ "$IPMethod" == "Static" ]
	then
		echo "Setting up static IP $IP ."
		echo "" >> /home/pi/config/dhcpcd.conf
		echo "interface wlan0" >> /home/pi/config/dhcpcd.conf
		echo "static ip_address=$IP/24" >> /home/pi/config/dhcpcd.conf
		echo "static routers=$IPRouter" >> /home/pi/config/dhcpcd.conf
		echo "static domain_name_servers=$DNS1" >> /home/pi/config/dhcpcd.conf
		echo "static domain_name_servers=$DNS2" >> /home/pi/config/dhcpcd.conf
	elif [ "$IPMethod" == "DHCP" ]
	then
		echo "Setting up without static IP."
	else
		echo "Warning: IPMethod not defined."
	fi

	if [ "$(diff /etc/network/interfaces /home/pi/config/interfaces.client.sample)" != "" ]
	then
		cp /home/pi/config/default.client.hostapd /etc/default/hostapd
		cp /home/pi/config/interfaces.client.sample /etc/network/interfaces
		echo "Rebooting..."
		shutdown -r now
	fi

elif [ "$WifiMode" == "AccessPoint" ]
then
	echo "Setting up in access point mode."
	echo "" >> /home/pi/config/dhcpcd.conf
	echo "denyinterfaces wlan0" >> /home/pi/config/dhcpcd.conf

	cat /home/pi/config/hostapd.conf.sample1 > /home/pi/config/hostapd.conf
	echo -e "\n# This is the name of the network\nssid=$HOSTNAME" >> /home/pi/config/hostapd.conf
	cat /home/pi/config/hostapd.conf.sample2 >> /home/pi/config/hostapd.conf
	echo -e "# The network passphrase\nwpa_passphrase=$RSA" >> /home/pi/config/hostapd.conf
	cat /home/pi/config/hostapd.conf.sample3 >> /home/pi/config/hostapd.conf
	if [ "$(diff /etc/hostapd/hostapd.conf /home/pi/config/hostapd.conf)" != "" ]
	then
		mv /home/pi/config/hostapd.conf /etc/hostapd/hostapd.conf
		tokenrestart="oui"
	fi
	if [ "$(diff /etc/default/hostapd /home/pi/config/default.accesspoint.hostapd)" != "" ]
	then
		cp /home/pi/config/default.accesspoint.hostapd /etc/default/hostapd
		tokenrestart="oui"
	fi

        if [ "$(diff /etc/network/interfaces /home/pi/config/interfaces.accesspoint.sample)" != "" ]
	then
		cp /home/pi/config/interfaces.accesspoint.sample /etc/network/interfaces
		tokenrestart="oui"
	fi
else
	echo "Warning: WifiMode not defined."
fi

if [ "$(diff /etc/dhcpcd.conf /home/pi/config/dhcpcd.conf)" == "" ]
then
	echo "DHCPCD settings up to date."
	rm /home/pi/config/dhcpcd.conf
else
	echo "Updating DHCPCD settings..."
	mv /home/pi/config/dhcpcd.conf /etc/dhcpcd.conf
	tokenrestart="oui"
fi

if [ "$SSH" == "enabled" ]
then
	echo "Checking if SSH is enabled..."
	testssh=$(ps -e | grep sshd)

	if [[ "$testssh" == "" ]]
	then
	        echo "SSH is not active, activating..."
		sudo touch /boot/ssh
		tokenrestart="oui"
	else
		echo "SSH already active, nothing to do..."
	fi
fi

if [ "$tokenrestart" == "oui" ]
then
	echo "Rebooting..."
	shutdown -r now
fi
