#!/bin/bash

#resolving sudo: unable to resolve host <vnf-name>
x=$(cat /etc/hostname)
sudo sed -i "1s/.*/127.0.0.1 localhost $x/" /etc/hosts
echo "changing hostname --> $x"

#auto discovery by zabbix
#updating Server=localhost --> Server=10.0.0.5 for discovery by zabbix server as host
line=$(sudo grep -n "Server=localhost" /etc/zabbix/zabbix_agentd.conf | sed 's/^\([0-9]\+\):.*$/\1/')
echo "changing Server=localhost --> $line"

if ! [ -z "$line" ]
then
  echo "Inside 1st condition"
  sudo sed -i "${line}s/.*/Server=10.0.0.5/" /etc/zabbix/zabbix_agentd.conf
fi

#updating ServerActive=localhost:10051 --> ServerActive=10.0.0.5 for discovery by zabbix server as host
line=$(sudo grep -n "ServerActive=localhost:10051$" /etc/zabbix/zabbix_agentd.conf | sed 's/^\([0-9]\+\):.*$/\1/')
echo "changing ServerActive=localhost:10051 --> $line"

if ! [ -z "$line" ]
then
  echo "Inside 2nd condition"
  sudo sed -i "${line}s/.*/ServerActive=10.0.0.5:10051\n/" /etc/zabbix/zabbix_agentd.conf
fi

sudo systemctl restart zabbix-agent.service 
echo "restarted zabbix-agent.service"
