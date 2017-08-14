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

CASSANDRA_PORT=${ANALYTICS_cassandra_port:-9042}
ZOOKEEPER_PORT=${CONFIG_zookeeoer_port:-2181}
ANALYTICS_COLLECTOR_PORT=${ANALYTCS_COLLECTOR_analytics_port:-8086}
ANALYTICS_API_HTTP_PORT=${ANALYTCS_API_http_port:-8090}
ANALYTICS_API_REST_API_PORT=${ANALYTCS_API_rest_api_port:-8081}
RABBITMQ_PORT=${CONFIG__rabbit_port:-5672}
REDIS_PORT=${ANALYTICS_redis_port:-6379}
REDIS_QUERY_PORT=${ANALYTICS_redis_port:-6379}
KAFKA_PORT=${COLLECTOR_kafka_port:-9092}
CONFIG_PORT=${COLLECTOR_config_port:-8082}

read -r -d '' collector_config << EOM
[DEFAULT]
analytics_data_ttl=${COLLECTOR_analytics_data_ttl:-48}
analytics_config_audit_ttl=${COLLECTOR_analytics_config_audit_ttl:-2160}
analytics_statistics_ttl=${COLLECTOR_analytics_statistics_ttl:-168}
analytics_flow_ttl=${COLLECTOR_analytics_flow_ttl:-2}

cassandra_server_list=${COLLECTOR_cassandra_server_list:-`get_server_list CASSANDRA "$CASSANDRA_PORT "`}
kafka_broker_list=${COLLECTOR_broker_broker_list:-`get_server_list KAFKA "$KAFKA_PORT "`}
zookeeper_server_list=${COLLECTOR_zookeeper_server_list:-`get_server_list ZOOKEEPER "$ZOOKEEPER_PORT,"`}
partitions=${COLLECTOR_partitions:-30}

hostip=${COLLECTOR_host_ip:-`get_listen_ip`}
# hostname= # Retrieved from gethostname() or `hostname -s` equivalent
http_server_port=${COLLECTOR_http_server_port:-8089}
# log_category=
log_file=${COLLECTOR_log_file:-/var/log/contrail/contrail-collector.log}
log_files_count=${COLLECTOR_log_files_count:-10}
log_file_size=${COLLECTOR_log_file_size:-1048576}
log_level=${COLLECTOR_log_level:-SYS_NOTICE}
log_local=${COLLECTOR_log_local:-1}
syslog_port=${COLLECTOR_syslog_port:-514}
sflow_port=${COLLECTOR_sflow_port:-6343}
ipfix_port=${COLLECTOR_:-4739}
# sandesh_send_rate_limit=

[COLLECTOR]
port=${COLLECTOR_port:-8086}
server=${COLLECTOR_server:-0.0.0.0}
protobuf_port=${COLLECTOR_protobuf_port:-3333}

[STRUCTURED_SYSLOG_COLLECTOR]
# TCP & UDP port to listen on for receiving structured syslog messages
port=${COLLECTOR_SYSLOG_port:-3514}

# List of external syslog receivers to forward structured syslog messages in ip:port format separated by space
# tcp_forward_destination=10.213.17.53:514

kafka_broker_list=${COLLECTOR_broker_broker_list:-`get_server_list KAFKA "$KAFKA_PORT "`}

kafka_topic=${COLLECTOR_kafka_topic:-structured_syslog_topic}

# number of kafka partitions
kafka_partitions=${COLLECTOR_kafka_partitions:-30}

[API_SERVER]
# List of api-servers in ip:port format separated by space
api_server_list=${COLLECTOR_api_server_list:-`get_server_list CONFIG "$CONFIG_PORT "`}
api_server_use_ssl=${COLLECTOR_api_server_use_ssl:-False}

[DATABASE]
# disk usage percentage
disk_usage_percentage.high_watermark0=${COLLECTOR_disk_usage_percentage_high_watermark0:-90}
disk_usage_percentage.low_watermark0=${COLLECTOR_disk_usage_percentage_low_watermark0:-85}
disk_usage_percentage.high_watermark1=${COLLECTOR_disk_usage_percentage_high_watermark1:-80}
disk_usage_percentage.low_watermark1=${COLLECTOR_disk_usage_percentage_low_watermark1:-75}
disk_usage_percentage.high_watermark2=${COLLECTOR_disk_usage_percentage_high_watermark2:-70}
disk_usage_percentage.low_watermark2=${COLLECTOR_disk_usage_percentage_low_watermark2:-60}

# Cassandra pending compaction tasks
pending_compaction_tasks.high_watermark0=${COLLECTOR_pending_compaction_tasks_high_watermark0:-400}
pending_compaction_tasks.low_watermark0=${COLLECTOR_pending_compaction_tasks_low_watermark0:-300}
pending_compaction_tasks.high_watermark1=${COLLECTOR_pending_compaction_tasks_high_watermark1:-200}
pending_compaction_tasks.low_watermark1=${COLLECTOR_pending_compaction_tasks_low_watermark1:-150}
pending_compaction_tasks.high_watermark2=${COLLECTOR_pending_compaction_tasks_high_watermark2:-100}
pending_compaction_tasks.low_watermark2=${COLLECTOR_pending_compaction_tasks_low_watermark2:-80}

# Message severity levels to be written to database
high_watermark0.message_severity_level=${COLLECTOR_high_watermark0_message_severity_level:-SYS_EMERG}
low_watermark0.message_severity_level=${COLLECTOR_low_watermark0_message_severity_level:-SYS_ALERT}
high_watermark1.message_severity_level=${COLLECTOR_high_watermark1_message_severity_level:-SYS_ERR}
low_watermark1.message_severity_level=${COLLECTOR_low_watermark1_message_severity_level:-SYS_WARN}
high_watermark2.message_severity_level=${COLLECTOR_high_watermark2_message_severity_level:-SYS_DEBUG}
low_watermark2.message_severity_level=${COLLECTOR_low_watermark2_message_severity_level:-INVALID}

[REDIS]
# Port to connect to for communicating with redis-server
#port=${COLLECTOR_REDIS_port:-6379}

# IP address of redis-server
server=${COLLECTOR_REDIS_server:-127.0.0.1}

[SANDESH]
sandesh_ssl_enable=${ANALYTICS_sandesh_ssl_enable:-False}
introspect_ssl_enable=${ANALYTICS_introspect_ssl_enable:-False}
sandesh_keyfile=${ANALYTICS_sandesh_keyfile:-/etc/contrail/ssl/private/server-privkey.pem}
sandesh_certfile=${ANALYTICS_sandesh_certfile:-/etc/contrail/ssl/certs/server.pem}
sandesh_ca_cert=${ANALYTICS_sandesh_ca_cert:-/etc/contrail/ssl/certs/ca-cert.pem}
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
echo "$collector_config" > /etc/contrail/contrail-collector.conf
if [ $CONFIG_API_auth="keystone" ]; then
  echo "$contrail_keystone_auth_config" > /etc/contrail/contrail-keystone-auth.conf
fi
echo "$vnc_api_lib_config" > /etc/contrail/vnc_api_lib.ini
exec "$@"
