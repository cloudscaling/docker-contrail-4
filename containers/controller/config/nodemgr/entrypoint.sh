#!/bin/bash

CONTROLLER_NODES=${CONTROLLER_NODES:-`hostname`}
ANALYTICS_NODES=${ANALYTICS_NODES:-${CONTROLLER_NODES}}

analytics_server_list=''
IFS=' ' read -ra server_list <<< "${ANALYTICS_NODES}"
for server in "${server_list[@]}"; do
  server_address=`echo ${server}`
  analytics_server_list+=$server_address:8086,
done
analytics_list="${analytics_server_list::-1}"

sed -i "s/#server_list=/server_list=/g" /etc/contrail/contrail-config-nodemgr.conf
sed -i "s/server_list=.*/server_list=${analytics_list}/g" /etc/contrail/contrail-config-nodemgr.conf

if [[ -n "$DEBUG" ]] ; then
   echo "Debug mode.."
   while [[ ! -f '/go' ]] ; do
     sleep 1
   done
   echo "Exit from debug mode"
fi

exec "$@"

