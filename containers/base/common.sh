#!/bin/bash

source /functions.sh

CONTROLLER_NODES=${CONTROLLER_NODES:-`get_listen_ip`}
ANALYTICS_NODES=${ANALYTICS_NODES:-${CONTROLLER_NODES}}
ZOOKEEPER_NODES=${ZOOKEEPER_NODES:-${CONTROLLER_NODES}}
CONFIG_NODES=${CONFIG_NODES:-${CONTROLLER_NODES}}
CASSANDRA_NODES=${CASSANDRA_NODES:-${CONTROLLER_NODES}}
RABBITMQ_NODES=${RABBITMQ_NODES:-${CONTROLLER_NODES}}

CONFIGDB_PORT=${CONFIGDB_PORT:-9160}
ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-2181}
RABBITMQ_PORT=${RABBITMQ_PORT:-5672}
CONFIG_API_PORT=${CONFIG_API_PORT:-8082}
ANALYTICS_API_PORT=${ANALYTCS_API_PORT:-8081}
COLLECTOR_PORT=${COLLECTOR_PORT:-8086}

LOG_DIR=${LOG_DIR:-"/var/log/contrail"}
LOG_LEVEL=${LOG_LEVEL:-SYS_NOTICE}

RABBITMQ_VHOST=${RABBITMQ_VHOST:-/}
RABBITMQ_USER=${RABBITMQ_USER:-guest}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD:-guest}

CONFIGDB_SERVERS=${CONFIGDB_SERVERS:-`get_server_list CASSANDRA ":$CONFIGDB_PORT "`}
ZOOKEEPER_SERVERS=${ZOOKEEPER_SERVERS:-`get_server_list ZOOKEEPER ":$ZOOKEEPER_PORT,"`}
RABBITMQ_SERVERS=${RABBITMQ_SERVERS:-`get_server_list RABBITMQ ":$RABBITMQ_PORT,"`}
ANALYTICS_SERVERS=${ANALYTICS_SERVERS:-`get_server_list ANALYTICS "$ANALYTICS_API_PORT "`}
COLLECTOR_SERVERS=${COLLECTOR_SERVERS:-`get_server_list ANALYTICS ":$COLLECTOR_PORT "`}

REDIS_SERVER_IP=${REDIS_SERVER_IP:-127.0.0.1}
REDIS_SERVER_PORT=${REDIS_SERVER_PORT:-6379}
REDIS_SERVER_PASSWORD=${REDIS_SERVER_PASSWORD:-""}


read -r -d '' sandesh_client_config << EOM
[SANDESH]
sandesh_ssl_enable=${SANDESH_SSL_ENABLE:-False}
introspect_ssl_enable=${INTROSPECT_SSL_ENABLE:-False}
sandesh_keyfile=${SANDESH_KEYFILE:-/etc/contrail/ssl/private/server-privkey.pem}
sandesh_certfile=${SANDESH_CERTFILE:-/etc/contrail/ssl/certs/server.pem}
sandesh_ca_cert=${SANDESH_CA_CERT:-/etc/contrail/ssl/certs/ca-cert.pem}
EOM


function set_third_party_auth_config(){
  if [ $CONFIG_API_auth="keystone" ]; then
    cat > /etc/contrail/contrail-keystone-auth.conf << EOM
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
  fi
}

function set_vnc_api_lib_ini(){
  cat > /etc/contrail/vnc_api_lib.ini << EOM
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
}
