FROM  10.87.64.33:5043/contrail-analytics-base:4.0.0.0-20
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-snmp-collector","--device-config-file","/etc/contrail/device.ini"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
