FROM  10.87.64.33:5043/contrail-analytics-base:4.0.1.0-23
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-query-engine","--conf_file","/etc/contrail/contrail-query-engine.conf"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
