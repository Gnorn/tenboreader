#!/bin/bash
#FAIT LORS DE LA REMISE EN ROUTE :

sudo apt-get -y update
sudo apt-get -y dist-upgrade
#gardé dhcpcd.conf ma version
#sudo shutdown -r now
sudo apt-get -y install apache2 apache2-doc avahi-daemon python-rpi.gpio
sudo apt-get -y install php7.0 libapache2-mod-php7.0
#decommenté dtparam=spi=on dans /boot/config.txt
sudo sh -c "echo 'dtparam=spi=on' >> /boot/config.txt"
sudo sh -c "echo 'dtoverlay=spi0-hw-cs' >> /boot/config.txt"
sudo rpi-update
#SPI EST ACTIVE
sudo apt-get -y install python-dev
sudo apt-get -y install git
wget https://pypi.python.org/packages/36/83/73748b6e1819b57d8e1df8090200195cdae33aaa22a49a91ded16785eedd/spidev-3.2.tar.gz
tar xvf spidev-3.2.tar.gz
cd spidev-3.2/
sudo python setup.py install
cd ..
sudo rm -r spidev-3.2
rm spidev-3.2.tar.gz
#copié readpoints.py et offsetconfig.py
#sudo touch /var/www/html/scores.csv
#sudo chmod 766 /var/www/html/scores.csv
#copié /var/www
#copié /etc/rc.local
#copié /home/pi/config
#copie /home/pi/config.sh
#copié /home/pi/calibrate.py
#copié /home/pi/updatehostname.sh
#copié /home/pi/calibrate.py
#copié /home/pi/systemupdate/
#copié /boot/TenboReader.cfg

sudo cp _etc/rc.local /etc/rc.local
sudo cp -r _home_pi/* /home/pi/
sudp cp -r _var_www_html/* /var/www/html/
sudo cp TenboReader.cfg /boot/TenboReader.cfg


#CREE IMAGE DISQUE TenboReader-restore1.img

# Ajouté les lignes suivantes dans sudo visudo :

echo "pi ALL=(ALL) ALL" | (sudo su -c 'EDITOR="tee -a" visudo')
echo "pi ALL=(ALL) NOPASSWD: /usr/bin/httpd.sh, /home/pi/launchreadpoints.sh" | (sudo su -c 'EDITOR="tee -a" visudo')
echo "www-data ALL=(ALL) NOPASSWD: /sbin/shutdown" | (sudo su -c 'EDITOR="tee -a" visudo')
echo "www-data ALL=(ALL) NOPASSWD: /home/pi/calibrate.py" | (sudo su -c 'EDITOR="tee -a" visudo')
echo "www-data ALL=(ALL) NOPASSWD: /home/pi/restartpoints.sh" | (sudo su -c 'EDITOR="tee -a" visudo')
echo "www-data ALL=(ALL) NOPASSWD: /home/pi/systemupdate/systemupdate.sh" | (sudo su -c 'EDITOR="tee -a" visudo')

##FIN D'AJOUT A VISUDO


sudo shutdown -r now

#CREE IMAGE DISQUE TenboReader0.8altRC.img
