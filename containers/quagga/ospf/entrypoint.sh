#!/bin/bash

function get_listen_ip(){
  default_interface=`ip route show |grep "default via" |awk '{print $5}'`
  default_ip_address=`ip address show dev $default_interface |\
                    head -3 |tail -1 |tr "/" " " |awk '{print $2}'`
  default_network=`ip route show |grep "dev ${default_interface}  proto kernel" |\
                    awk '{print $1}'`
}
get_listen_ip
cat <<EOF > /etc/quagga/ospf.conf
router ospf
 ospf router-id ${default_ip_address}
 log-adjacency-changes detail
 passive-interface default
 no passive-interface lo
 no passive-interface ${default_interface}
 network ${VIP} area 0.0.0.51
 network ${default_network} area 0.0.0.51
!
line vty
 exec-timeout 0 0
!
EOF
chown quagga:quagga /etc/quagga/ospf.conf
cat <<EOF > /etc/quagga/vtysh.conf
service integrated-vtysh-config
username root nopassword
EOF


exec "$@"
