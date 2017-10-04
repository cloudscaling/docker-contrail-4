FROM  localhost:5000/contrail-analytics-base:4.0.1.0-32
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-snmp-collector","--device-config-file","/etc/contrail/device.ini"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
