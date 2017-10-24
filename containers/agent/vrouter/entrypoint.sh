#!/bin/bash

CONTROLLER_NODES=${CONTROLLER_NODES:-`hostname`}
ANALYTICS_NODES=${ANALYTICS_NODES:-${CONTROLLER_NODES}}
ANALYTICS_REDIS_NODES=${ANALYTICS_REDIS_NODES:-${CONTROLLER_NODES}}
ZOOKEEPER_NODES=${ZOOKEEPER_NODES:-${CONTROLLER_NODES}}
CONFIG_NODES=${CONFIG_NODES:-${CONTROLLER_NODES}}
CASSANDRA_NODES=${CASSANDRA_NODES:-${CONTROLLER_NODES}}
RABBITMQ_NODES=${RABBITMQ_NODES:-${CONTROLLER_NODES}}
REDIS_NODES=${REDIS_NODES:-${CONTROLLER_NODES}}
CONTROL_NODES=${CONTROL_NODES:-${CONTROLLER_NODES}}
DNS_NODES=${DNS_NODES:-${CONTROLLER_NODES}}

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
CONFIG_PORT=${COLLECTOR_config_port:-8082}
CONTROL_PORT=${CONTROL_port:-5269}
DNS_PORT=${DNS_port:-53}

PHYS_INT=${PHYSICAL_INTERFACE:-`eth0`}
VROUTER_HOSTNAME=${VROUTER_HOSTNAME:-`hostname`}
VROUTER_IP=${VROUTER_IP:-`get_listen_ip`}
VROUTER_GW=${VROUTER_GW:-`ip route show |grep default|grep ${PHYS_INT}|awk '{print $3}'`}
DEV_MAC=$(cat /sys/class/net/${PHYS_INT}/address)

read -r -d '' contrail_vrouter_agent_config << EOM
[CONTROL-NODE]
servers=${CONFIG_control_nodes:-`get_server_list CONTROL "$CONTROL_PORT "`}

[DEFAULT]
collectors=${CONFIG_collectors:-`get_server_list ANALYTICS "$ANALYTICS_COLLECTOR_PORT "`}
log_file=/var/log/contrail/contrail-vrouter-agent.log
log_level=SYS_NOTICE
log_local=1

[DNS]
servers=${CONFIG_dns_server_list:-`get_server_list DNS "$DNS_PORT "`}

[METADATA]
Shared secret for metadata proxy service (Optional)
metadata_proxy_secret=contrail

[VIRTUAL-HOST-INTERFACE]
name=vhost0
ip=$VROUTER_IP
physical_interface=$PHYS_INT
gateway=$VROUTER_GW

[SERVICE-INSTANCE]
netns_command=/usr/bin/opencontrail-vrouter-netns
docker_command=/usr/bin/opencontrail-vrouter-docker
EOM

read -r -d '' vnc_api_lib_ini << EOM
[global]
# TODO: List is not taken here, change to VIP
WEB_SERVER = $CONFIG_NODES
WEB_PORT = $CONFIG_PORT

[auth]
AUTHN_TYPE = noauth
EOM

# VRouter specific code starts here

function pkt_setup () {
    for f in /sys/class/net/$1/queues/rx-*
    do
        q="$(echo $f | cut -d '-' -f2)"
        r=$(($q%32))
        s=$(($q/32))
        ((mask=1<<$r))
        str=(`printf "%x" $mask`)
        if [ $s -gt 0 ]; then
            for ((i=0; i < $s; i++))
            do
                str+=,00000000
            done
        fi
        echo $str > $f/rps_cpus
    done
    ifconfig $1 up
}

function insert_vrouter() {
    if [ -f /sys/class/net/pkt1/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt1
    fi
    if [ -f /sys/class/net/pkt2/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt2
    fi
    if [ -f /sys/class/net/pkt3/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt3
    fi
    vif --create vhost0 --mac $DEV_MAC
    vif --add ${PHYS_INT} --mac $DEV_MAC --vrf 0 --vhost-phys --type physical
    vif --add vhost0 --mac $DEV_MAC --vrf 0 --type vhost --xconnect ${PHYS_INT}
    ip link set vhost0 up
    return 0
}

# Load kernel module
echo "Modprobing vrouter"
modprobe vrouter

echo "Inserting vrouter"
insert_vrouter

echo "Changing physical interface to vhost in ip table"
if [[ `ifconfig ${PHYS_INT} |grep "inet "` ]]; then
  def_gw=''
  if [[ `ip route show |grep default|grep ${PHYS_INT}` ]]; then
        # TODO: rework - VROUTER_GW definition code is extracted from here 
        def_gw=$VROUTER_GW
  fi
  ip=`ifconfig ${PHYS_INT} |grep "inet "|awk '{print $2}'`
  mask=`ifconfig ${PHYS_INT} |grep "inet "|awk '{print $4}'`
  ip address delete $ip/$mask dev ${PHYS_INT}
  ip address add $ip/$mask dev vhost0
  if [[ $def_gw ]]; then
    ip route add default via $def_gw
  fi
fi

# Prepare agent configs
echo "Preparing configs"
echo "$contrail_vrouter_agent_config" > /etc/contrail/contrail-vrouter-agent.conf
echo "$vnc_api_lib_ini" > /etc/contrail/vnc_api_lib.ini

# Prepare default_pmac
echo $DEV_MAC > /etc/contrail/default_pmac

# Provision vrouter
echo "Provisioning vrouter"
/usr/share/contrail-utils/provision_vrouter.py  --api_server_ip $CONTROLLER_NODES
    --host_name $VROUTER_HOSTNAME --host_ip $VROUTER_IP --oper add
