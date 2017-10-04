FROM localhost:5000/contrail-controller-config-base:4.0.1.0-32
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf", "-n"]
#CMD ["/usr/bin/contrail-nodemgr","--nodetype=contrail-config"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
