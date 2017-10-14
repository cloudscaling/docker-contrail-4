FROM localhost:5000/contrail-controller-config-base:4.0.1.0-32
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-api","--conf_file","/etc/contrail/contrail-api.conf","--conf_file","/etc/contrail/contrail-keystone-auth.conf","--worker_id","0"]
LABEL net.juniper.nodemgr.filter.name=contrail-api
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
