#!/bin/bash

set -e

CONFIG="$ZOO_CONF_DIR/zoo.cfg"

echo "clientPort=$ZOO_PORT" >> "$CONFIG"
echo "dataDir=$ZOO_DATA_DIR" >> "$CONFIG"
echo "dataLogDir=$ZOO_DATA_LOG_DIR" >> "$CONFIG"

echo "tickTime=$ZOO_TICK_TIME" >> "$CONFIG"
echo "initLimit=$ZOO_INIT_LIMIT" >> "$CONFIG"
echo "syncLimit=$ZOO_SYNC_LIMIT" >> "$CONFIG"

IFS=' ' read -ra server_list <<< "${!ZOO_SERVERS_*}"
for server in "${server_list[@]}"; do
  server_name=`echo $server |awk -F"_" '{print $3}'`
  server_index=`echo $server |awk -F"_" '{print $4}'`
  server_address=`echo ${!server}`
  echo "${server_name}.${server_index}=${server_address}:2888:3888" >> "$CONFIG"
done
echo "${ZOO_MY_ID:-1}" > "$ZOO_DATA_DIR/myid"

exec "$@"
