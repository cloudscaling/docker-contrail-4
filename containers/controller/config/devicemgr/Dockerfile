FROM 10.87.64.33:5043/contrail-controller-config-base:4.0.0.0-20
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-device-manager","--conf_file","/etc/contrail/contrail-device-manager.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
