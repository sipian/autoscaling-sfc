#!/bin/bash

OPENBATON_PLUGINS_VIMDRIVERS_STABLE_URL="http://get.openbaton.org/plugins/stable/"
OPENBATON_TMP_FOLDER=`mktemp -d`
OPENBATON_INSTALLATION_BASE_DIR=/opt
OPENBATON_BASE_DIR="${OPENBATON_INSTALLATION_BASE_DIR}/openbaton"
OPENBATON_BASE_CONFIG_DIR="/etc/openbaton"
OPENBATON_LOG="/var/log/openbaton"
OPENBATON_NFVO_DIR="${OPENBATON_BASE_DIR}/nfvo"
OPENBATON_PLUGINS_DIR="${OPENBATON_NFVO_DIR}/plugins"
OPENBATON_PLUGINS_VIMDRIVERS_DIR="${OPENBATON_PLUGINS_DIR}/vim-drivers"

OPENBATON_SRC_NFVO_CONFIG_FILE_NAME="openbaton.properties"
OPENBATON_SRC_NFVO_CONFIG_FILE_ABSOLUTHE="${OPENBATON_BASE_CONFIG_DIR}/${OPENBATON_SRC_NFVO_CONFIG_FILE_NAME}"

RABBITMQ_BROKER_IP_DEFAULT=10.0.0.
RABBITMQ_MANAGEMENT_PORT_DEFAULT=15672
OPENBATON_ADMIN_PASSWORD_DEFAULT=openbaton

OPENBATON_NFVO_IP_DEFAULT=localhost

OPENBATON_FMS_MYSQL_USER_DEFAULT=fmsuser
OPENBATON_FMS_MYSQL_USER_PASSWORD_DEFAULT=root
OPENBATON_MYSQL_ROOT_PASSWORD_DEFAULT=root



src_configure_rabbitmq () {
    result=$(ps aux | grep -v 'grep' | grep 'rabbitmq' | wc -l)
    if [ ${result} -gt 0 ]; then
        result=$(sudo rabbitmqctl list_users| grep '^admin' | wc -l)
        if [ ${result} -eq 0 ]; then
            sudo rabbitmqctl add_user admin openbaton
            sudo rabbitmqctl set_user_tags admin administrator
            sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
            sudo rabbitmq-plugins enable rabbitmq_management
            sudo service rabbitmq-server restart
            if [ "$?" != "0" ]; then
                echo " * ERROR: RabbitMQ is NOT running properly (check the problem in /var/log/rabbitmq)"
                exit 1
            fi
        fi
    fi

    export OPENBATON_SRC_NFVO_CONFIG_FILE_ABSOLUTHE=${OPENBATON_SRC_NFVO_CONFIG_FILE_ABSOLUTHE}

    # Set the rabbitmq broker ip
    export rabbitmq_broker_ip=${rabbitmq_broker_ip:-$RABBITMQ_BROKER_IP_DEFAULT}
    echo " * Setting new broker IP: ${rabbitmq_broker_ip}"
    sudo sed -i "s|nfvo.rabbit.brokerIp\s*=\s*localhost|nfvo.rabbit.brokerIp=${rabbitmq_broker_ip}|g" ${OPENBATON_SRC_NFVO_CONFIG_FILE_ABSOLUTHE}

    # Set the rabbitmq management port
    export rabbitmq_management_port=${rabbitmq_management_port:-$RABBITMQ_MANAGEMENT_PORT_DEFAULT}
    sudo sed -i "s|nfvo.rabbit.management.port\s*=\s*15672|nfvo.rabbit.management.port=${rabbitmq_management_port}|g" ${OPENBATON_SRC_NFVO_CONFIG_FILE_ABSOLUTHE}
}


check_binary () {
  echo -n " * Checking for '${1}' ... "
  if command -v ${1} >/dev/null 2>&1; then
     echo "OK"
     return 0
  else
     echo >&2 "FAILED"
     return 1
  fi
}



x=$(cat /etc/hostname)
sudo sed -i "1s/.*/127.0.0.1 localhost $x/" /etc/hosts
echo "changing hostname --> $x"

sudo apt-get update
sudo apt-get -y install openjdk-8-jdk curl wget screen git


sudo git clone --recursive "https://github.com/openbaton/NFVO.git" "${OPENBATON_NFVO_DIR}"
cd "${OPENBATON_NFVO_DIR}"
sudo mv ./dashboard ../
sudo git checkout tags/3.0.1
sudo mv ../dashboard ./dashboard
cd dashboard
sudo git checkout tags/3.0.0
cd ..

sudo rm -rf "${OPENBATON_BASE_CONFIG_DIR}; sudo mkdir -p ${OPENBATON_BASE_CONFIG_DIR}"
sudo cp "${OPENBATON_NFVO_DIR}/etc/openbaton.properties ${OPENBATON_SRC_NFVO_CONFIG_FILE_ABSOLUTHE}"
sudo cp "${OPENBATON_NFVO_DIR}/etc/keystore.p12 ${OPENBATON_BASE_CONFIG_DIR}/keystore.p12"

wget -nH --cut-dirs 2 -r --no-parent  --reject "index.html*" "${OPENBATON_PLUGINS_VIMDRIVERS_STABLE_URL}" -P "${OPENBATON_TMP_FOLDER}"
sudo mkdir -p ${OPENBATON_PLUGINS_VIMDRIVERS_DIR}
sudo cp -r ${OPENBATON_TMP_FOLDER}/* "${OPENBATON_PLUGINS_VIMDRIVERS_DIR}"


sudo apt-get install -y rabbitmq-server
ulimit -S -n 4096
src_configure_rabbitmq


error=0
echo " * Checking environment .."
check_binary java; error=$(($error + $?))
check_binary javac; error=$(($error + $?))
check_binary curl; error=$(($error + $?))
check_binary screen; error=$(($error + $?))
check_binary wget; error=$(($error + $?))
if [ "0" != "$error" ]; then
  echo >&2 " * ERROR: Please install the above mentioned binaries."
  exit 1
fi

#git clone "https://github.com/openbaton/generic-vnfm.git" "${OPENBATON_NFVO_DIR}"
