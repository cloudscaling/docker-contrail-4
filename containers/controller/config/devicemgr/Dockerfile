FROM localhost:5000/contrail-controller-config-base:4.0.1.0-32
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-device-manager","--conf_file","/etc/contrail/contrail-device-manager.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]
LABEL net.juniper.nodemgr.filter.name=contrail-device-manager
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
