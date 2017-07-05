#!/bin/bash
set -e

analytics_server_list=''
IFS=' ' read -ra server_list <<< "${!ANALYTICS_SERVERS_*}"
for server in "${server_list[@]}"; do
  server_address=`echo ${!server}`
  analytics_server_list+=$server_address:8086,,
done
analytics_list="${analytics_server_list::-1}"

sed -i 's/server_list =.*/server_list = ${analytics_list}/g' /etc/contrail/contrail-config-nodemgr.conf

exec "$@"

