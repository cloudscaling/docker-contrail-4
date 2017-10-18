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
    extended_server_list+=${server_address}${port}
  done
  extended_list="${extended_server_list::-1}"
  echo ${extended_list}
}

CASSANDRA_PORT=${CONFIG_cassandra_port:-9160}
ZOOKEEPER_PORT=${CONFIG_zookeeoer_port:-2181}
ANALYTICS_COLLECTOR_PORT=${ANALYTCS_COLLECTOR_analytics_port:-8086}
ANALYTICS_API_HTTP_PORT=${ANALYTCS_API_http_port:-8090}
ANALYTICS_API_REST_API_PORT=${ANALYTCS_API_rest_api_port:-8081}
RABBITMQ_PORT=${CONFIG__rabbit_port:-5672}
REDIS_PORT=${ANALYTICS_redis_port:-6379}
KAFKA_PORT=${ALARM_GEN_kafka_port:-9092}
CONFIG_API_PORT=${CONFIG_api_port:-8082}

if [ $K8S_TOKEN_FILE ]; then
  K8S_TOKEN=$(cat $K8S_TOKEN_FILE)
fi

read -r -d '' kube_manager_config << EOM
[DEFAULTS]
log_local = 1
log_level = SYS_DEBUG
log_file = /var/log/contrail/contrail-kube-manager.log
orchestrator = kubernetes
token = $K8S_TOKEN
[KUBERNETES]
kubernetes_api_server = ${KUBERNETES_api_server:-`get_listen_ip`}
kubernetes_api_port = ${KUBERNETES_api_port:-8080}
kubernetes_api_secure_port = ${KUBERNETES_api_secure_port:-6443}
service_subnets = ${KUBERNETES_service_subnets:-"10.96.0.0/12"}
pod_subnets = ${KUBERNETES_pod_subnets:-"10.32.0.0/12"}
cluster_project = ${KUBERNETES_cluster_project:-"{'domain': 'default-domain', 'project': 'default'}"}
cluster_name = ${KUBERNETES_cluster_name:-"k8s-default"}
;cluster_network = ${KUBERNETES_cluster_network:-"{}"}
[VNC]
vnc_endpoint_ip = `get_server_list CONFIG ","`
vnc_endpoint_port = $CONFIG_API_PORT
rabbit_server = ${CONFIG_rabbit_server:-`get_server_list RABBITMQ ":$RABBITMQ_PORT,"`}
rabbit_vhost = ${CONFIG_rabbit_vhost:-/}
rabbit_user = ${CONFIG_rabbit_user:-guest}
rabbit_password = ${CONFIG_rabbit_password:-guest}
cassandra_server_list = ${CONFIG_cassandra_server_list:-`get_server_list CASSANDRA ":$CASSANDRA_PORT "`}
public_fip_pool = ${KUBERNETES_public_fip_pool:-"{}"}
collectors = ${CONFIG_collectors:-`get_server_list ANALYTICS ":$ANALYTICS_COLLECTOR_PORT "`}
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

echo "$kube_manager_config" > /etc/contrail/contrail-kubernetes.conf
if [ $CONFIG_API_auth="keystone" ]; then
  echo "$contrail_keystone_auth_config" > /etc/contrail/contrail-keystone-auth.conf
fi
echo "$vnc_api_lib_config" > /etc/contrail/vnc_api_lib.ini
exec "$@"
