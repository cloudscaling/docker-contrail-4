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
  server_list=''
  IFS=',' read -ra server_list <<< "${!server_typ}"
  for server in "${server_list[@]}"; do
    server_address=`echo \'${server}\'`
    extended_server_list+=${server_address},
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

read -r -d '' webui_config << EOM
/*
 * Copyright (c) 2014 Juniper Networks, Inc. All rights reserved.
 */

var config = {};

config.orchestration = {};
config.orchestration.Manager = ${orchestration_Manager:-'none'};

config.serviceEndPointFromConfig = ${serviceEndPointFromConfig:-true};

config.regionsFromConfig = ${regionsFromConfig:-false};

config.endpoints = {};
config.endpoints.apiServiceType = ${endpoints_apiServiceType:-'ApiServer'};
config.endpoints.opServiceType = ${endpoints_apiServiceType:-'OpServer'};

config.regions = {};
config.regions.RegionOne = ${regions_RegionOne:-'http://127.0.0.1:5000/v2.0'};

config.serviceEndPointTakePublicURL = ${serviceEndPointTakePublicURL:-true};

config.networkManager = {};
config.networkManager.ip = ${networkManager_ip:-'127.0.0.1'};
config.networkManager.port = ${networkManager_port:-'9696'};
config.networkManager.authProtocol = ${networkManager_authProtocol:-'http'};
config.networkManager.apiVersion = ${networkManager_apiVersion:-[]};
config.networkManager.strictSSL = ${networkManager_strictSSL:-false};
config.networkManager.ca = ${networkManager_ca:-''};

config.imageManager = {};
config.imageManager.ip = ${imageManager_ip:-'127.0.0.1'};
config.imageManager.port = ${imageManager_port:-'9292'};
config.imageManager.authProtocol = ${imageManager_authProtocol:-'http'};
config.imageManager.apiVersion = ${imageManager_apiVersion:-['v1', 'v2']};
config.imageManager.strictSSL = ${imageManager_strictSSL:-false};
config.imageManager.ca = ${imageManager_ca:-''};

config.computeManager = {};
config.computeManager.ip = ${computeManager_ip:-'127.0.0.1'};
config.computeManager.port = ${computeManager_port:-'8774'};
config.computeManager.authProtocol = ${computeManager_authProtocol:-'http'};
config.computeManager.apiVersion = ${computeManager_apiVersion:-['v1.1', 'v2']};
config.computeManager.strictSSL = ${computeManager_strictSSL:-false};
config.computeManager.ca = ${computeManager_ca:-''};

config.identityManager = {};
config.identityManager.ip = ${identityManager_ip:-'127.0.0.1'};
config.identityManager.port = ${identityManager_port:-'5000'};
config.identityManager.authProtocol = ${identityManager_authProtocol:-'http'};
config.identityManager.apiVersion = ${identityManager_apiVersion:-['v2.0']};
config.identityManager.strictSSL = ${identityManager_strictSSL:-false};
config.identityManager.ca = ${identityManager_ca:-''};

config.storageManager = {};
config.storageManager.ip = ${storageManager_ip:-'127.0.0.1'};
config.storageManager.port = ${storageManager_port:-'8776'};
config.storageManager.authProtocol = ${storageManager_authProtocol:-'http'};
config.storageManager.apiVersion = ${storageManager_apiVersion:-['v1']};
config.storageManager.strictSSL = ${storageManager_strictSSL:-false};
config.storageManager.ca = ${storageManager_ca:-''};

config.cnfg = {};
config.cnfg.server_ip = [${cnfg_server_ip:-`get_server_list CONFIG`}];
config.cnfg.server_port = ${cnfg_server_port:-'8082'};
config.cnfg.authProtocol = ${cnfg_authProtocol:-'http'};
config.cnfg.strictSSL = ${cnfg_strictSSL:-false};
config.cnfg.ca = ${cnfg_ca:-''};
config.cnfg.statusURL = ${cnfg_statusURL:-'"/global-system-configs"'};

config.analytics = {};
config.analytics.server_ip = [${analytics_server_ip:-`get_server_list ANALYTICS`}];
config.analytics.server_port = ${analytics_server_port:-'8081'};
config.analytics.authProtocol = ${analytics_authProtocol:-'http'};
config.analytics.strictSSL = ${analytics_strictSSL:-false};
config.analytics.ca = ${analytics_ca:-''};
config.analytics.statusURL = ${analytics_statusURL:-'"/analytics/uves/bgp-peers"'};

config.dns = {};
config.dns.server_ip = [${dns_server_ip:-`get_server_list CONFIG`];
config.dns.server_port = ${dns_server_port:-'8092'};
config.dns.statusURL = ${dns_statusURL:-'"/Snh_PageReq?x=AllEntries%20VdnsServersReq"'};

config.vcenter = {}};
config.vcenter.server_ip = '127.0.0.1';         //vCenter IP
config.vcenter.server_port = '443';             //Port
config.vcenter.authProtocol = 'https';          //http or https
config.vcenter.datacenter = 'vcenter';          //datacenter name
config.vcenter.dvsswitch = 'vswitch';           //dvsswitch name
config.vcenter.strictSSL = false;               //Validate the certificate or ignore
config.vcenter.ca = '';                         //specify the certificate key file
config.vcenter.wsdl = '/usr/src/contrail/contrail-web-core/webroot/js/vim.wsdl';

config.introspect = {};
config.introspect.ssl = {};
config.introspect.ssl.enabled = false;
config.introspect.ssl.key = '';
config.introspect.ssl.cert = '';
config.introspect.ssl.ca = '';
config.introspect.ssl.strictSSL = false;

config.jobServer = {};
config.jobServer.server_ip = '127.0.0.1';
config.jobServer.server_port = '3000';

config.files = {};
config.files.download_path = '/tmp';

config.cassandra = {};
config.cassandra.server_ips = [${cassandra_server_ips:-`get_server_list CASSANDRA`}];
config.cassandra.server_port = ${cassandra_server_port:-'9042'};
config.cassandra.enable_edit = ${cassandra_enable_edi:-false};

config.kue = {};
config.kue.ui_port = '3002'

config.webui_addresses = ['0.0.0.0'];

config.insecure_access = false;

config.http_port = '8080';

config.https_port = '8143';

config.require_auth = false;

config.node_worker_count = 1;

config.maxActiveJobs = 10;

config.redisDBIndex = 3;

config.CONTRAIL_SERVICE_RETRY_TIME = 300000; //5 minutes

config.redis_server_port = '6379';
config.redis_server_ip = '127.0.0.1';
config.redis_dump_file = '/var/lib/redis/dump-webui.rdb';
config.redis_password = '';

config.logo_file = '/usr/src/contrail/contrail-web-core/webroot/img/opencontrail-logo.png';

config.favicon_file = '/usr/src/contrail/contrail-web-core/webroot/img/opencontrail-favicon.ico';

config.featurePkg = {};
config.featurePkg.webController = {};
config.featurePkg.webController.path = '/usr/src/contrail/contrail-web-controller';
config.featurePkg.webController.enable = true;

config.qe = {};
config.qe.enable_stat_queries = false;

config.logs = {};
config.logs.level = 'debug';

config.getDomainProjectsFromApiServer = false;
config.network = {};
config.network.L2_enable = false;

config.getDomainsFromApiServer = false;
config.jsonSchemaPath = "/usr/src/contrail/contrail-web-core/src/serverroot/configJsonSchemas";
module.exports = config;
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
echo "$webui_config" > /etc/contrail/config.global.js
echo "$vnc_api_lib_config" > /etc/contrail/vnc_api_lib.ini
exec "$@"
