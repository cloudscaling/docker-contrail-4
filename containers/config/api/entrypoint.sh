#!/bin/bash

function get_listen_ip(){
  default_interface=`ip route show |grep "default via" |awk '{print $5}'`
  default_ip_address=`ip address show dev $default_interface |\
                    head -3 |tail -1 |tr "/" " " |awk '{print $2}'`
  echo ${default_ip_address}
}

function get_server_list(){
  server_typ=$1
  port=$2
  server_list=''
  case $server_typ in
  ANALYTICS)
    IFS=' ' read -ra server_list <<< "${!ANALYTICS_SERVERS_*}"
    ;;
  ZOOKEEPER)
    IFS=' ' read -ra server_list <<< "${!ZOO_SERVERS_*}"
    ;;
  CONFIG)
    IFS=' ' read -ra server_list <<< "${!CONFIG_SERVERS_*}"
    ;;
  CASSANDRA)
    IFS=' ' read -ra server_list <<< "${!CASSANDRA_SERVERS_*}"
    ;;
  RABBIT)
    IFS=' ' read -ra server_list <<< "${!RABBITMQ_SERVERS_*}"
    ;;
  esac
  for server in "${server_list[@]}"; do
    server_address=`echo ${!server}`
    extended_server_list+=${server_address}:${port}
  done
  extended_list="${extended_server_list::-1}"
  echo ${extended_list}
}

CASSANDRA_PORT=${CONFIG_API_cassandra_port:-9160}
ZOOKEEPER_PORT=${CONFIG_API_zookeeoer_port:-2181}
ANALYTICS_PORT=${CONFIG_API_analytics_port:-8086}
RABBIT_PORT=${CONFIG_API_rabbit_port:-8086}

read -r -d '' contrail_api_config << EOM
[DEFAULTS]
log_file=${CONFIG_API_log_file:-/var/log/contrail/contrail-api.log}
log_level=${CONFIG_API_log_level:-SYS_NOTICE}
cassandra_server_list=${CONFIG_API_cassandra_server_list:-`get_server_list CASSANDRA "$CASSANDRA_PORT "`}
zk_server_ip=${CONFIG_API_zk_server_ip:-`get_server_list ZOOKEEPER "$ZOOKEEPER_PORT,"`}
rabbit_vhost=${CONFIG_API_rabbit_vhost:-/}
collectors=${CONFIG_API_collectors:-`get_server_list ANALYTICS "$ANALYTICS_PORT "`}
listen_ip_addr=${CONFIG_API_listen_ip_addr:-`get_listen_ip`}
list_optimization_enabled=${CONFIG_API_list_optimization_enabled:-True}
rabbit_password=${CONFIG_API_rabbit_password:-guest}
rabbit_server=${CONFIG_API_rabbit_server:-`get_server_list RABBIT "$RABBIT_PORT,"`}
listen_port=${CONFIG_API_LISTEN_PORT:-8082}
rabbit_user=${CONFIG_API_rabbit_user:-guest}
aaa_mode=${CONFIG_API_aaa_mode:-no-auth}
redis_server=${CONFIG_API_redis_server:-127.0.0.1}
auth=${CONFIG_API_auth:-""}

[SANDESH]
sandesh_ssl_enable=${CONFIG_API_sandesh_ssl_enable:-False}
introspect_ssl_enable=${CONFIG_API_introspect_ssl_enable:-False}
sandesh_keyfile=${CONFIG_API_sandesh_keyfile:-/etc/contrail/ssl/private/server-privkey.pem}
sandesh_certfile=${CONFIG_API_sandesh_certfile:-/etc/contrail/ssl/certs/server.pem}
sandesh_ca_cert=${CONFIG_API_sandesh_ca_cert:-/etc/contrail/ssl/certs/ca-cert.pem}
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
WEB_PORT = ${CONFIG_API_LISTEN_PORT:-8082} ; connection to api-server directly
BASE_URL = /
;BASE_URL = /tenants/infra ; common-prefix for all URLs

; Authentication settings (optional)
[auth]
;AUTHN_TYPE = keystone
;AUTHN_PROTOCOL = http
;AUTHN_SERVER = 127.0.0.1
AUTHN_SERVER = ${CONFIG_API_AUTHN_SERVER:-""}
;AUTHN_PORT = 35357
;AUTHN_URL = /v2.0/tokens
;AUTHN_TOKEN_URL = http://127.0.0.1:35357/v2.0/tokens
EOM

#get_kv
echo "$contrail_api_config" > /etc/contrail/contrail-api.conf
if [ $CONFIG_API_auth == "keystone" ]; then
  echo "$contrail_keystone_auth_config" > /etc/contrail/contrail-keystone-auth.conf
fi
echo "$vnc_api_lib_config" > /etc/contrail/vnc_api_lib.ini
exec "$@"
