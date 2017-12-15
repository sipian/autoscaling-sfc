#!/bin/bash


ip=$(ip -f inet -o addr show ens3|cut -d\  -f 7 | cut -d/ -f 1;)

line=$(sudo grep -n "rabbitmq_broker_ip=" bootstrap-config-file | sed 's/^\([0-9]\+\):.*$/\1/')
sudo sed -i "${line}s/.*/rabbitmq_broker_ip=${ip}/" bootstrap-config-file


chmod +x bootstrap
chmod +x bootstrap-common-functions
chmod +x bootstrap-deb-functions
chmod +x bootstrap-src-functions
./bootstrap develop --config-file=/home/ubuntu/autoscaling-sfc/bootstrap/bootstrap-config-file