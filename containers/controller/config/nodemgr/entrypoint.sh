#!/bin/bash

source /common.sh

sed -i "s/#server_list=/server_list=/g" /etc/contrail/contrail-config-nodemgr.conf
sed -i "s/server_list=.*/server_list=${COLLECTOR_SERVERS}/g" /etc/contrail/contrail-config-nodemgr.conf

exec "$@"

