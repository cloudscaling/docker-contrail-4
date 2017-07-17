FROM 10.87.64.33:5043/contrail-controller-config-base:4.0.1.0-23
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-svc-monitor","--conf_file","/etc/contrail/contrail-svc-monitor.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
