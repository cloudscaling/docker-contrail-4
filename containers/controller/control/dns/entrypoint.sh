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

read -r -d '' contrail_control_named << EOM
options {
    directory "/etc/contrail/dns/";
    managed-keys-directory "/etc/contrail/dns/";
    empty-zones-enable no;
    pid-file "/etc/contrail/dns/contrail-named.pid";
    session-keyfile "/etc/contrail/dns/session.key";
    listen-on port 53 { any; };
    allow-query { any; };
    allow-recursion { any; };
    allow-query-cache { any; };
    max-cache-size 32M;
};

key "rndc-key" {
    algorithm hmac-md5;
    secret "xvysmOR8lnUQRBcunkC6vg==";
};

controls {
    inet 127.0.0.1 port 8094
    allow { 127.0.0.1; }  keys { "rndc-key"; };
};

logging {
    channel debug_log {
        file "/var/log/contrail/contrail-named.log" versions 3 size 5m;
        severity debug;
        print-time yes;
        print-severity yes;
        print-category yes;
    };
    category default {
        debug_log;
    };
    category queries {
        debug_log;
    };
};
EOM

read -r -d '' contrail_control_rndc << EOM
key "rndc-key" {
    algorithm hmac-md5;
    secret "xvysmOR8lnUQRBcunkC6vg==";
};

options {
    default-key "rndc-key";
    default-server 127.0.0.1;
    default-port 8094;
};
EOM

read -r -d '' contrail_control_dns << EOM
[DEFAULT]
collectors = ${CONFIG_collectors:-`get_server_list ANALYTICS "$ANALYTICS_COLLECTOR_PORT "`}
# dns_config_file=dns_config.xml
named_config_file = ${DNS_named_config_file:-contrail-named.conf}
named_config_directory = ${DNS_named_config_directory:-/etc/contrail/dns}
named_log_file = ${DNS_named_log_file:-/var/log/contrail/contrail-named.log}
rndc_config_file = ${DNS_rndc_config_file:-contrail-rndc.conf}
#rndc_secret=${DNS_rnd_secret:-secret==$}                                 # rndc secret
named_max_cache_size=${DNS_named_max_cache_size:-32M} # max-cache-size (bytes) per view, can be in K or M
named_max_retransmissions=${DNS_named_max_retransmissions:-12}
named_retransmission_interval=${DNS_named_retransmission_interval:-1000} # msec
hostip = ${DNS_hostip:-`get_listen_ip`}
hostname = ${DNS_hostname:-`hostname`}
http_server_port = ${DNS_http_server_port:-8092}
dns_server_port = ${DNS_dns_server_port:-53}
# log_category= ${DNS_log_category:-""}
# log_disable= ${DNS_log_disable:-0}
log_file = ${DNS_log_file:-/var/log/contrail/contrail-dns.log}
# log_files_count=${DNS_log_files_count:-10}
# log_file_size= ${DNS_log_file_size:-1048576} # 1MB
log_level = ${DNS_log_level:-SYS_NOTICE}
log_local = ${DNS_log_local:-1}
# test_mode=0
# log_property_file= # log4cplus property file
xmpp_dns_auth_enable = ${DNS_xmpp_dns_auth_enable:-False}
# xmpp_server_cert=${DNS_xmpp_server_cert:-/etc/contrail/ssl/certs/server.pem}
# xmpp_server_key=${DNS_xmpp_server_key:-/etc/contrail/ssl/private/server-privkey.pem}
# xmpp_ca_cert=${DNS_xmpp_ca_cert:-/etc/contrail/ssl/certs/ca-cert.pem}

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
echo "$contrail_control_dns" > /etc/contrail/contrail-dns.conf
echo "$contrail_control_rndc" > /etc/contrail/dns/contrail-rndc.conf
#echo "$contrail_control_named" > /etc/contrail/dns/contrail-named.conf
#chown contrail:contrail /etc/contrail/dns/contrail-named.conf
#touch /var/log/contrail/contrail-named.log
#chown contrail:contrail /var/log/contrail/contrail-named.log
#chown contrail:contrail /var/log/contrail
if [ $CONFIG_API_auth="keystone" ]; then
  echo "$contrail_keystone_auth_config" > /etc/contrail/contrail-keystone-auth.conf
fi
echo "$vnc_api_lib_config" > /etc/contrail/vnc_api_lib.ini
exec "$@"
