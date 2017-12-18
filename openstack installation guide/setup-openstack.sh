#!/bin/bash
read -p "Enter Your public IP address: " IP
$password="root"


function install_openstack {
  sudo apt-get upgrade
  sudo apt-get update

  sudo apt-get install -y python-systemd
  sudo useradd -s /bin/bash -d /opt/stack -m stack
  echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

  sudo su -l stack
  git clone --branch stable/pike  https://git.openstack.org/openstack-dev/devstack
  cd /opt/stack/devstack

  echo "
  [[local|localrc]]
  ADMIN_PASSWORD=secret
  DATABASE_PASSWORD=$ADMIN_PASSWORD
  RABBIT_PASSWORD=$ADMIN_PASSWORD
  SERVICE_PASSWORD=$ADMIN_PASSWORD
  HOST_IP=$IP" > local.conf

  sudo echo -e "\n\n$IP devstack" >> /etc/hosts
  ./stack.sh
}

function setup-openstack {
  echo "modifying defualt security group"


  sudo sysctl -w net.ipv4.ip_forward=1

  echo 1 > /proc/sys/net/ipv4/ip_forward
  /sbin/iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
  /sbin/iptables -A FORWARD -i eno1 -o br-ex -m state --state RELATED,ESTABLISHED -j ACCEPT
  /sbin/iptables -A FORWARD -i br-ex -o eno1 -j ACCEPT
  /sbin/iptables -t nat -A PREROUTING -s 192.168.136.0/24 -i eno1  -j REDIRECT 


  openstack image create --public --disk-format qcow2 --container-format bare --file xenial-server-cloudimg-amd64-disk1.img ubuntu


  
  default_security_group=$(openstack security group list --project admin -c ID -f value)

  openstack security group rule create \
  --remote-ip 0.0.0.0/0 \
  --protocol icmp \
  --ingress \
  --project admin \
  --description "allow all ingress ICMP" \
  $default_security_group

  openstack security group rule create \
  --remote-ip 0.0.0.0/0 \
  --protocol icmp \
  --egress \
  --project admin \
  --description "allow all egress ICMP" \
  $default_security_group

  #TCP
  openstack security group rule create \
  --remote-ip 0.0.0.0/0 \
  --dst-port 1:65535 \
  --protocol tcp \
  --ingress \
  --project admin \
  --description "allow all ingress TCP" \
  $default_security_group

  openstack security group rule create \
  --remote-ip 0.0.0.0/0 \
  --dst-port 1:65535 \
  --protocol tcp \
  --egress \
  --project admin \
  --description "allow all egress TCP" \
  $default_security_group

  #UDP
  openstack security group rule create \
  --remote-ip 0.0.0.0/0 \
  --dst-port 1:65535 \
  --protocol udp \
  --ingress \
  --project admin \
  --description "allow all ingress TCP" \
  $default_security_group
  
  openstack security group rule create \
  --remote-ip 0.0.0.0/0 \
  --dst-port 1:65535 \
  --protocol udp \
  --egress \
  --project admin \
  --description "allow all egress TCP" \
  $default_security_group

  echo "add rule for ssh"


}

install_openstack
echo "openstack-password -> secret"
