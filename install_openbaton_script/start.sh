#!/bin/bash

chmod +x ./zabbix_server.sh
./zabbix_server.sh

brokerIp="$(ip -f inet -o addr show ens3|cut -d\  -f 7 | cut -d/ -f 1;)"
