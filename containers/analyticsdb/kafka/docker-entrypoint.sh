#!/bin/bash

set -e

default_interface=`ip route show |grep "default via" |awk '{print $5}'`
default_ip_address=`ip address show dev $default_interface |head -3 |tail -1 |tr "/" " " |awk '{print $2}'`
: ${KAFKA_LISTEN_ADDRESS='auto'}
if [ "$KAFKA_LISTEN_ADDRESS" = 'auto' ]; then
        KAFKA_LISTEN_ADDRESS=${default_ip_address}
fi
CONFIG="$KAFKA_CONF_DIR/server.properties"
CONTROLLER_NODES=${CONTROLLER_NODES:-`hostname`}
ZOOKEEPER_NODES=${ZOOKEEPER_NODES:-${CONTROLLER_NODES}}
zk_server_list=''
server_index=1
IFS=',' read -ra server_list <<< "${ZOOKEEPER_NODES}"
for server in "${server_list[@]}"; do
  zk_server_list+=${server}:2181,
  if [ ${default_ip_address} == $server ]; then
    my_index=$server_index
  fi
  server_index=$((server_index+1))
done
zk_list="${zk_server_list::-1}"
KAFKA_BROKER_ID=${my_index:-1}
sed -i "s/^zookeeper.connect=.*$/zookeeper.connect=$zk_list/g" ${CONFIG}
sed -i "s/^broker.id=.*$/broker.id=$KAFKA_BROKER_ID/g" ${CONFIG}
sed -i "s/^#advertised.host.name=.*$/advertised.host.name=$KAFKA_LISTEN_ADDRESS/g" ${CONFIG}

exec "$@"
