#!/bin/bash

x=$(cat /etc/hostname)
echo "changing hostname --> $x"
sudo sed -i "1s/.*/127.0.0.1 localhost $x/" /etc/hosts


echo "installing mysql : root password as root"

sudo apt-get -y upgrade
sudo apt-get update

sudo apt-get install -y apache2 git
sudo ufw allow in "Apache Full"

#mysql
sudo apt -y install zsh htop    
    
echo "insalling mysql : give password as root"
echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections    

sudo apt-get install -y mysql-server-5.7

#php
sudo apt-get install -y php libapache2-mod-php php-mcrypt php-mysql

sudo sed -i "s_DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm_DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm_g" /etc/apache2/mods-enabled/dir.conf

sudo systemctl restart apache2

echo "installing zabbix server"
sudo apt-get install -y php7.0-xml php7.0-bcmath php7.0-mbstring
mkdir -p $HOME/zabbix-server
cd $HOME/zabbix-server

wget http://repo.zabbix.com/zabbix/3.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.0-2+xenial_all.deb
sudo dpkg -i zabbix-release_3.0-2+xenial_all.deb
sudo apt-get update
sudo apt-get install -y zabbix-server-mysql zabbix-frontend-php
mysql --user="root" --password="root" --execute="create database zabbix character set utf8 collate utf8_bin;"
mysql --user="root" --password="root" --execute="grant all privileges on zabbix.* to zabbix@localhost identified by 'root';"
mysql --user="root" --password="root" --execute="flush privileges;"
echo "insert password - root"
zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uzabbix -proot zabbix

sudo sed -i "s_# DBPassword=_DBPassword=root_g" /etc/zabbix/zabbix_server.conf
sudo sed -i "s+# php_value date.timezone Europe/Riga+php_value date.timezone Asia/Kolkata+g" /etc/zabbix/apache.conf

sudo systemctl restart apache2
sudo systemctl start zabbix-server
sudo systemctl enable zabbix-server
@&^#