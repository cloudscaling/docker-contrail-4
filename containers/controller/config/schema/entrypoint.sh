#!/bin/bash

CONTROLLER_NODES=${CONTROLLER_NODES:-`hostname`}
ANALYTICS_NODES=${ANALYTICS_NODES:-${CONTROLLER_NODES}}
ZOOKEEPER_NODES=${ZOOKEEPER_NODES:-${CONTROLLER_NODES}}
CONFIG_NODES=${CONFIG_NODES:-${CONTROLLER_NODES}}
CASSANDRA_NODES=${CASSANDRA_NODES:-${CONTROLLER_NODES}}
RABBITMQ_NODES=${RABBITMQ_NODES:-${CONTROLLER_NODES}}

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

CASSANDRA_PORT=${CONFIG_cassandra_port:-9160}
ZOOKEEPER_PORT=${CONFIG_zookeeoer_port:-2181}
ANALYTICS_PORT=${CONFIG_analytics_port:-8086}
ANALYTICS_COLLECTOR_PORT=${ANALYTCS_COLLECTOR_analytics_port:-8086}
RABBITMQ_PORT=${CONFIG_rabbit_port:-5672}
CONFIG_API_PORT=${CONFIG_api_server_port:-8082}
CONFIG_API_IP=${CONFIG_api_server_ip:-${VIP}}

read -r -d '' contrail_schema_config << EOM
[DEFAULTS]
log_file=${CONFIG_SCHEMA_log_file:-/var/log/contrail/contrail-schema.log}
log_level=${CONFIG_SCHEMA_log_level:-SYS_NOTICE}
api_server_ip = ${CONFIG_API_IP:-`get_listen_ip`}
api_server_port = ${CONFIG_api_server_port:-8082}
cassandra_server_list=${CONFIG_cassandra_server_list:-`get_server_list CASSANDRA "$CASSANDRA_PORT "`}
zk_server_ip=${CONFIG_zk_server_ip:-`get_server_list ZOOKEEPER "$ZOOKEEPER_PORT,"`}
rabbit_vhost=${CONFIG_rabbit_vhost:-/}
rabbit_password=${CONFIG_rabbit_password:-guest}
rabbit_server=${CONFIG_rabbit_server:-`get_server_list RABBITMQ "$RABBITMQ_PORT,"`}
rabbit_user=${CONFIG_rabbit_user:-guest}
redis_server=${CONFIG_redis_server:-127.0.0.1}
collectors=${CONFIG_collectors:-`get_server_list ANALYTICS "$ANALYTICS_COLLECTOR_PORT "`}

[SANDESH]
sandesh_ssl_enable=${CONFIG_sandesh_ssl_enable:-False}
introspect_ssl_enable=${CONFIG_introspect_ssl_enable:-False}
sandesh_keyfile=${CONFIG_sandesh_keyfile:-/etc/contrail/ssl/private/server-privkey.pem}
sandesh_certfile=${CONFIG_sandesh_certfile:-/etc/contrail/ssl/certs/server.pem}
sandesh_ca_cert=${CONFIG_sandesh_ca_cert:-/etc/contrail/ssl/certs/ca-cert.pem}
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
echo "$contrail_schema_config" > /etc/contrail/contrail-schema.conf
if [ $CONFIG_API_auth="keystone" ]; then
  echo "$contrail_keystone_auth_config" > /etc/contrail/contrail-keystone-auth.conf
fi
echo "$vnc_api_lib_config" > /etc/contrail/vnc_api_lib.ini
exec "$@"
