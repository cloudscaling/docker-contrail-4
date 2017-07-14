#!/bin/bash

CONTROLLER_NODES=${CONTROLLER_NODES:-`hostname`}
ANALYTICS_NODES=${ANALYTICS_NODES:-${CONTROLLER_NODES}}
ZOOKEEPER_NODES=${ZOOKEEPER_NODES:-${CONTROLLER_NODES}}
CONFIG_NODES=${CONFIG_NODES:-${CONTROLLER_NODES}}
CASSANDRA_NODES=${CASSANDRA_NODES:-${CONTROLLER_NODES}}
RABBITMQ_NODES=${RABBITMQ_NODES:-${CONTROLLER_NODES}}
REDIS_NODES=${REDIS_NODES:-${CONTROLLER_NODES}}
KAFKA_NODES=${KAFKA_NODES:-${CONTROLLER_NODES}}

function get_listen_ip(){
  default_interface=`ip route show |grep "default via" |awk '{print $5}'`
  default_ip_address=`ip address show dev $default_interface |\
                    head -3 |tail -1 |tr "/" " " |awk '{print $2}'`
  echo ${default_ip_address}
}

function get_server_list(){
  server_typ=$1_NODES
  port=$2
  server_list=''
  IFS=',' read -ra server_list <<< "${!server_typ}"
  for server in "${server_list[@]}"; do
    server_address=`echo ${server}`
    extended_server_list+=${server_address}:${port}
  done
  extended_list="${extended_server_list::-1}"
  echo ${extended_list}
}

CASSANDRA_PORT=${ANALYTICS_cassandra_port:-9043}
ZOOKEEPER_PORT=${CONFIG_zookeeoer_port:-2181}
ANALYTICS_COLLECTOR_PORT=${ANALYTCS_COLLECTOR_analytics_port:-8086}
ANALYTICS_API_HTTP_PORT=${ANALYTCS_API_http_port:-8090}
ANALYTICS_API_REST_API_PORT=${ANALYTCS_API_rest_api_port:-8081}
RABBITMQ_PORT=${CONFIG__rabbit_port:-5672}
REDIS_PORT=${ANALYTICS_redis_port:-6379}
KAFKA_PORT=${ALARM_GEN_kafka_port:-9092}
CONFIG_PORT=${COLLECTOR_config_port:-8082}

read -r -d '' snmp_collector_config << EOM
[DEFAULTS]
collectors=${SNMP_COLLECTOR_collectors:-`get_server_list ANALYTICS "$ANALYTICS_COLLECTOR_PORT "`}
fast_scan_frequency=${SNMP_COLLECTOR_fast_scan_frequency:-60}
http_server_port=${SNMP_COLLECTOR_http_server_port:-5920}
log_local = ${SNMP_COLLECTOR_log_local:-1}
log_level = ${SNMP_COLLECTOR_log_level:-SYS_NOTICE}
log_file = ${SNMP_COLLECTOR_log_file:-/var/log/contrail/contrail-snmp-collector.log}
scan_frequency=${SNMP_COLLECTOR_scan_frequency:-600}
zookeeper=${SNMP_COLLECTOR_zookeeper:-`get_server_list ZOOKEEPER "$ZOOKEEPER_PORT,"`}

[API_SERVER]
api_server_list=${SNMP_COLLECTOR_api_server_list:-`get_server_list CONFIG "$CONFIG_PORT "`}
api_server_use_ssl=${SNMP_COLLECTOR_api_server_use_ssl:-False}

[SANDESH]
introspect_ssl_enable=${SNMP_COLLECTOR_introspect_ssl_enable:-False}
sandesh_keyfile=${SNMP_COLLECTOR_sandesh_keyfile:-/etc/contrail/ssl/private/server-privkey.pem}
sandesh_certfile=${SNMP_COLLECTOR_sandesh_certfile:-/etc/contrail/ssl/certs/server.pem}
sandesh_ca_cert=${SNMP_COLLECTOR_sandesh_ca_cert:-/etc/contrail/ssl/certs/ca-cert.pem}
EOM

read -r -d '' contrail_keystone_auth_config << EOM
[KEYSTONE]
admin_password = PQWmBFprabzGZz7rAZyxXQXYb
admin_tenant_name = admin
admin_token = eDmvqUxPGrt7qp2YX67MtfF7T
admin_user = admin
auth_host = 192.168.24.12
auth_port = 35357
auth_protocol = http
insecure = false
memcached_servers = 127.0.0.1:12111
EOM

read -r -d '' vnc_api_lib_config << EOM
[global]
;WEB_SERVER = 127.0.0.1
;WEB_PORT = 9696  ; connection through quantum plugin

WEB_SERVER = 127.0.0.1
WEB_PORT = ${CONFIG_api_server_port:-8082}
BASE_URL = /
;BASE_URL = /tenants/infra ; common-prefix for all URLs

; Authentication settings (optional)
[auth]
;AUTHN_TYPE = keystone
;AUTHN_PROTOCOL = http
;AUTHN_SERVER = 127.0.0.1
AUTHN_SERVER = ${CONFIG_AUTHN_SERVER:-""}
;AUTHN_PORT = 35357
;AUTHN_URL = /v2.0/tokens
;AUTHN_TOKEN_URL = http://127.0.0.1:35357/v2.0/tokens
EOM

#get_kv
echo "$snmp_collector_config" > /etc/contrail/contrail-snmp-collector.conf
if [ $CONFIG_API_auth="keystone" ]; then
  echo "$contrail_keystone_auth_config" > /etc/contrail/contrail-keystone-auth.conf
fi
echo "$vnc_api_lib_config" > /etc/contrail/vnc_api_lib.ini
exec "$@"
