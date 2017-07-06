#!/bin/bash

default_interface=`ip route show |grep "default via" |awk '{print $5}'`
default_ip_address=`ip address show dev $default_interface |\
                  head -3 |tail -1 |tr "/" " " |awk '{print $2}'`
default_network=`ip route show |grep "dev ${default_interface}  proto kernel" |\
                  awk '{print $1}'`
cat <<EOF > /etc/quagga/zebra.conf
hostname Router
password zebra
enable password zebra
EOF
if [ -n ${OSPF_HA} ]; then
ip address add ${VIP} dev lo
cat <<EOF >> /etc/quagga/zebra.conf
interface ${default_interface}
 ipv6 nd suppress-ra
 no link-detect
!
interface lo
 no link-detect
!
EOF
fi
cat <<EOF > /etc/quagga/vtysh.conf
service integrated-vtysh-config
username root nopassword
EOF

exec "$@"
