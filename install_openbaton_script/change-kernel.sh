#!/bin/bash

cd $HOME
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.2-wily/linux-headers-4.2.0-040200-generic_4.2.0-040200.201510260713_amd64.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.2-wily/linux-headers-4.2.0-040200_4.2.0-040200.201510260713_all.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.2-wily/linux-image-4.2.0-040200-generic_4.2.0-040200.201510260713_amd64.deb

sudo dpkg -i *.deb

sudo apt-get -y purge --auto-remove  linux-headers-4.4*
sudo apt-get -y purge --auto-remove  linux-image-4.4*


sudo update-grub 
sudo reboot now