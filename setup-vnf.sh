#!/bin/bash
read -p "Enter Your public IP address: " IP
password="root"

function install_dependences {
  sudo apt-get upgrade
  sudo apt-get update

  sudo apt-get install -y curl

  #apache 2
  sudo apt-get install -y apache2
  sudo ufw allow in "Apache Full"
  
  #mysql
  echo "insalling mysql , give password as root"
  sleep 3
  sudo apt-get install -y mysql-server

  #php
  sudo apt-get install -y php libapache2-mod-php php-mcrypt php-mysql
  a=$(sudo sed -n -e "/^\s*DirectoryIndex/p" /etc/apache2/mods-enabled/dir.conf)
  a=${a// index.php / }
  a=${a//DirectoryIndex/DirectoryIndex index.php}
  N=$(sudo grep -n "\s*DirectoryIndex" /etc/apache2/mods-enabled/dir.conf | sed 's/^\([0-9]\+\):.*$/\1/')
  echo "${N}s/.*/$a/"
  sudo sed -i "${N}s/.*/$a/" /etc/apache2/mods-enabled/dir.conf

  sudo systemctl restart apache2
  sudo systemctl status apache2
  sleep 3
}

function install_openbaton {
  mkdir  openbaton_installation || { echo 'mkdir openbaton_installation failed. Already exists' ; exit 1; }
  cd openbaton_installation
  echo  "
# This is a configuration file for the Open Baton bootstrap. 
# It allows you to specify the parameters needed during the bootstrap for the configuration of the Open Baton projects.
#
# Usage: sh <(curl -s http://get.openbaton.org/bootstrap) [help | clean | enable-persistence | configure-remote-rabbitmq] | [[upgrade] [--openbaton-components=<all | openbaton-xxx,openbaton-yyy,...>]] | [[release | develop] [--openbaton-bootstrap-version=X.Y.Z (with X.Y.Z >= 3.2.0)] [--config-file=<absolute path to configuration file>]]
#
# IMPORTANT NOTE: Avoid spaces before and after the '=': i.e. a parameter needs to be specified as 'parameter=value'


#################
#### General ####
#################

openbaton_bootstrap_version=latest                          # Deafult is 'latest' therefore if left empty ('openbaton_bootstrap_version=') or commented the bootstrap used will be the latest. Use format X.Y.Z for a specific version: the oldest VERSION installable is 3.2.0
openbaton_installation_mode=noninteractive                  # Deafult is 'interactive' therefore if left empty ('openbaton_installation_mode=') or commented the installation will be interactive. Use 'noninteractive' or 'Noninteractive' for a not interactive installation
openbaton_component_autostart=true                          # Deafult is 'true' therefore if left empty ('openbaton_component_autostart=') or commented the debian component will start automatically at the end of the installation


##############
#### NFVO ####
##############

rabbitmq_broker_ip=$IP                                # Default is 'localhost' therefore if left empty ('rabbitmq_broker_ip=') or commented the 'localhost' value will be used
rabbitmq_management_port=15672                              # Default is '15672' therefore if left empty ('rabbitmq_management_port=') or commented the '15672' value will be used
openbaton_nfvo_ip=localhost                                 # Default is 'localhost' therefore if left empty ('openbaton_nfvo_ip=') or commented the 'localhost' value will be used
openbaton_admin_password=openbaton                          # Default is 'openbaton' therefore if left empty ('openbaton_admin_password=') or commented the 'openbaton' value will be used

https=no                                                    # Default is 'NO' therefore if left empty ('https=') or commented the HTTPS will NOT be enabled
mysql=yes                                                   # Default is 'YES' therefore if left empty ('mysql=') or commented the MYSQL DB will be installed and the Open Baton persistence will be enabled
mysql_root_password=root                                    # Default is 'root' therefore if left empty ('mysql_root_password=') or commented the 'root' value will be used (NOTE: you should insert here the actual mysql root password if mysql is already installed in the system)
openbaton_nfvo_mysql_user=admin                             # Default is 'admin' therefore if left empty ('openbaton_nfvo_mysql_user=') or commented the 'admin' value will be used
openbaton_nfvo_mysql_user_password=root                 # Default is 'changeme' therefore if left empty ('openbaton_nfvo_mysql_user_password=') or commented the 'changeme' value will be used


##########################################
#### Open Baton additional components ####
##########################################

openbaton_plugin_vimdriver_test=yes                         # Default is 'YES' therefore if left empty ('openbaton_plugin_vimdriver_test=') or commented the 'openbaton_plugin_vimdriver_test' driver will be installed (this option is valid only for develop installation)
openbaton_plugin_vimdriver_openstack=yes                    # Default is 'YES' therefore if left empty ('openbaton_plugin_vimdriver_openstack=') or commented the 'openbaton_plugin_vimdriver_openstack' debian package will be installed
openbaton_plugin_monitoring_zabbix=yes                       # Default is 'NO' therefore if left empty ('openbaton_plugin_monitoring_zabbix=') or commented the 'openbaton_plugin_monitoring_zabbix' debian package will be installed
openbaton_vnfm_generic=yes                                  # Default is 'YES' therefore if left empty ('openbaton_vnfm_generic=') or commented the 'openbaton_vnfm_generic' debian package will be installed
openbaton_fms=yes                                           # Default is 'NO' therefore if left empty ('openbaton_fms=') or commented the 'openbaton_fms' debian package will NOT be installed
openbaton_ase=yes                                           # Default is 'NO' therefore if left empty ('openbaton_ase=') or commented the 'openbaton_ase' debian package will NOT be installed
openbaton_nse=yes                                           # Default is 'NO' therefore if left empty ('openbaton_nse=') or commented the 'openbaton_nse' debian package will NOT be installed

# NOTE: The VERSION is to be interptreted as 'debian package version' or 'source TAG' respectively for RELEASE / DEVELOP installation
# Possible values are: 'latest' (only for RELEASE), 'develop' (only for DEVELOP), 'X.Y.Z' (for both types of installation)
openbaton_nfvo_version=5.1.1                                # Default is 'latest' / 'develop' therefore if left empty ('openbaton_nfvo_version=') or commented the 'latest' debian version / the 'develop' TAG will be installed. NOTE: Check the list of available tags at: https://github.com/openbaton/generic-vnfm/tags - The oldest VERSION installable is 3.2.0
openbaton_plugin_vimdriver_test_version=5.1.0               # Default is 'latest' / 'develop' therefore if left empty ('openbaton_plugin_vimdriver_test_version=') or commented the 'latest' debian version / the 'develop' TAG will be installed. NOTE: Check the list of available tags at: https://github.com/openbaton/openstack4j-plugin/tags - The oldest VERSION installable is 3.2.0
openbaton_plugin_vimdriver_openstack_version=5.1.1          # Default is 'latest' / 'develop' therefore if left empty ('openbaton_plugin_vimdriver_openstack_version=') or commented the 'latest' debian version / the 'develop' TAG will be installed. NOTE: Check the list of available tags at: https://github.com/openbaton/openstack4j-plugin/tags - The oldest VERSION installable is 3.2.0
openbaton_plugin_monitoring_zabbix_version=5.0.0            # Default is 'latest' / 'develop' therefore if left empty ('openbaton_plugin_monitoring_zabbix_version=') or commented the 'latest' debian version / the 'develop' TAG will be installed. NOTE: Check the list of available tags at: https://github.com/openbaton/zabbix-plugin/tags - The oldest VERSION installable is 3.2.0
openbaton_vnfm_generic_version=5.1.0                        # Default is 'latest' / 'develop' therefore if left empty ('openbaton_vnfm_generic_version=') or commented the 'latest' debian version / the 'develop' TAG will be deployed. NOTE: Check the list of available tags at: https://github.com/openbaton/generic-vnfm/tags - The oldest VERSION installable is 3.2.0
openbaton_fms_version=1.3.0                                 # Default is 'latest' / 'develop' therefore if left empty ('openbaton_fms_version=') or commented the 'latest' debian version / the 'develop' TAG will be deployed. NOTE: Check the list of available tags at: https://github.com/openbaton/fm-system/tags - The oldest VERSION installable is 1.2.1
openbaton_ase_version=1.3.0                                 # Default is 'latest' / 'develop' therefore if left empty ('openbaton_ase_version=') or commented the 'latest' debian version / the 'develop' TAG will be deployed. NOTE: Check the list of available tags at: https://github.com/openbaton/autoscaling-engine/tags - The oldest VERSION installable is 1.2.2
openbaton_nse_version=1.1.2                                 # Default is 'latest' / 'develop' therefore if left empty ('openbaton_nse_version=') or commented the 'latest' debian version / the 'develop' TAG will be deployed. NOTE: Check the list of available tags at: https://github.com/openbaton/network-slicing-engine/tags - The oldest VERSION installable is 1.1.2


#############
#### FMS ####
#############

openbaton_fms_mysql_user=fmsuser                            # Default is 'fmsuser' therefore if left empty ('mysql_user=') or commented the 'admin' value will be used
openbaton_fms_mysql_user_password=root                  # Default is 'changeme' therefore if left empty ('mysql_user_password=') or commented the 'changeme' value will be used


######################################################
#### Zabbix Plugin (required by FMS, ASE and NSE) ####
######################################################

# NOTE: Currently the ZABBIX configuration parameters are supported only for the RELEASE installation 
zabbix_plugin_ip=                                           # Default is 'localhost' therefore if left empty ('zabbix_plugin_ip=') or commented the 'admin' value will be used
zabbix_server_ip=                                           # Default is 'localhost' therefore if left empty ('zabbix_server_ip=') or commented the 'admin' value will be used
zabbix_user=                                                # Default is 'Admin' therefore if left empty ('zabbix_user=') or commented the 'Admin' value will be used
zabbix_user_password=                                       # Default is 'zabbix' therefore if left empty ('zabbix_user_password=') or commented the 'zabbix' value will be used
  " > current_openbaton.config

  pwd=$(pwd)
  file="$pwd/current_openbaton.config"
  sh <(curl -s http://get.openbaton.org/bootstrap) release --config-file=$file
  cd ..
  rm -rf openbaton_installation/
  rm current_openbaton.config
}


function install_zabbixserver {
  sudo apt-get -y upgrade
  sudo apt-get update
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
  zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uzabbix -p zabbix

  line=$(sudo grep -n "# DBPassword=" /etc/zabbix/zabbix_server.conf | sed 's/^\([0-9]\+\):.*$/\1/')
  sudo sed -i '${line}s/.*/DBPassword=root/' /etc/zabbix/zabbix_server.conf

  line=$(sudo grep -n "# php_value date.timezone Europe/Riga" /etc/zabbix/apache.conf | sed 's/^\([0-9]\+\):.*$/\1/')
  sudo sed -i '${line}s/.*/# php_value date.timezone Asia/Kolkata' /etc/zabbix/zabbix_server.conf


  echo "Follow the remaining steps after zcat from this link https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-zabbix-to-securely-monitor-remote-servers-on-ubuntu-16-04#step-1-%E2%80%94-installing-the-zabbix-server"
  sleep 3
}

install_dependences
# install_openbaton
# install_zabbixserver

"$@"

echo "all mysql passwords -> root"
echo "openbaton password for admin -> openbaton"
echo "zabbix password for Admin -> zabbix"
