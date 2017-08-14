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

CASSANDRA_PORT=${CONFIG_cassandra_port:-9041}
ZOOKEEPER_PORT=${CONFIG_zookeeoer_port:-2181}
ANALYTICS_COLLECTOR_PORT=${ANALYTCS_COLLECTOR_analytics_port:-8086}
RABBITMQ_PORT=${CONFIG_rabbit_port:-5672}

read -r -d '' contrail_control_config << EOM
[DEFAULT]
# bgp_config_file=bgp_config.xml
bgp_port = ${CONTROL_bgp_port:-179}
collectors = ${CONFIG_collectors:-`get_server_list ANALYTICS "$ANALYTICS_COLLECTOR_PORT "`}
# gr_helper_bgp_disable=0
# gr_helper_xmpp_disable=0
hostip = ${CONTROL_hostip:-`get_listen_ip`}
hostname = ${CONTROL_hostname:-`hostname`}
http_server_port = ${CONTROL_http_server_port:-8083}
# log_category= ${CONTROL_log_category:-""}
# log_disable= ${CONTROL_log_disable:-0}
log_file = ${CONTROL_log_file:-/var/log/contrail/contrail-control.log}
# log_files_count=${CONTROL_log_files_count:-10}
# log_file_size=${CONTROL_log_file_size:-10485760} # 10MB
log_level = ${CONTROL_log_level:-SYS_NOTICE}
log_local = ${CONTROL_log_local:-1}
# test_mode=0
xmpp_auth_enable = ${CONTROL_xmpp_auth_enable:-False}
# xmpp_server_cert=${CONTROL_xmpp_server_cert:-/etc/contrail/ssl/certs/server.pem}
# xmpp_server_key=${CONTROL_xmpp_server_key:-/etc/contrail/ssl/private/server-privkey.pem}
# xmpp_ca_cert=${CONTROL_xmpp_ca_cert:-/etc/contrail/ssl/certs/ca-cert.pem}
xmpp_server_port = ${CONTROL_xmpp_server_port:-5269}

# Sandesh send rate limit can be used to throttle system logs transmitted per
# second. System logs are dropped if the sending rate is exceeded
# sandesh_send_rate_limit=

[CONFIGDB]
# AMQP related configs
rabbitmq_server_list = ${CONFIG_rabbit_server:-`get_server_list RABBITMQ "$RABBITMQ_PORT,"`}
rabbitmq_user = ${CONFIG_rabbit_user:-guest}
rabbitmq_password = ${CONFIG_rabbit_password:-guest}
rabbitmq_vhost = ${CONFIG_rabbit_vhost:-/}
rabbitmq_use_ssl = ${CONFIG_rabbitmq_use_ssl:-False}
# rabbitmq_ssl_version=
# rabbitmq_ssl_keyfile=
# rabbitmq_ssl_certfile=
# rabbitmq_ssl_ca_certs=
#
config_db_server_list = ${CONFIG_cassandra_server_list:-`get_server_list CASSANDRA "$CASSANDRA_PORT "`}
# config_db_username=
# config_db_password=

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
echo "$contrail_control_config" > /etc/contrail/contrail-control.conf
if [ $CONFIG_API_auth="keystone" ]; then
  echo "$contrail_keystone_auth_config" > /etc/contrail/contrail-keystone-auth.conf
fi
echo "$vnc_api_lib_config" > /etc/contrail/vnc_api_lib.ini
IFS=',' read -ra CONFIG_NODE_LIST <<< "${CONFIG_NODES}"
CONFIG_NODE=${CONFIG_NODE_LIST[0]}
/opt/contrail/utils/provision_control.py --host_name ${CONTROL_hostname:-`hostname`} --host_ip ${CONTROL_hostip:-`get_listen_ip`} --router_asn ${CONTROL_asn:-64512} \
--api_server_port ${CONFIG_port:-8082} --oper add --admin_password ${ADMIN_PASSWORD:-contrail123} --admin_tenant_name ${ADMIN_TENANT:-admin} \
--admin_user ${ADMIN_USER:-admin} --api_server_ip ${CONFIG_NODE}
exec "$@"
