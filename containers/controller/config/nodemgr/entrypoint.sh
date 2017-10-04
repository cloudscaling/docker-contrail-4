#!/bin/bash

CONTROLLER_NODES=${CONTROLLER_NODES:-`hostname`}
ANALYTICS_NODES=${ANALYTICS_NODES:-${CONTROLLER_NODES}}

read -r -d '' supervisord_nodemgr_config << EOM
[program:nodemgr]
command=/usr/bin/contrail-nodemgr --nodetype=${NODE_TYPE:-contrail-config}
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOM

analytics_server_list=''
IFS=' ' read -ra server_list <<< "${ANALYTICS_NODES}"
for server in "${server_list[@]}"; do
  server_address=`echo ${server}`
  analytics_server_list+=$server_address:8086,
done
analytics_list="${analytics_server_list::-1}"

sed -i "s/#server_list=/server_list=/g" /etc/contrail/contrail-config-nodemgr.conf
sed -i "s/server_list=.*/server_list=${analytics_list}/g" /etc/contrail/contrail-config-nodemgr.conf

echo "$supervisord_nodemgr_config" >> /etc/supervisord.conf

exec "$@"

