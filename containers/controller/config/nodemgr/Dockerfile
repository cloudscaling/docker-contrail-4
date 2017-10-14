FROM localhost:5000/contrail-controller-config-base:4.0.1.0-32
COPY entrypoint.sh /
RUN yum install -y contrail-nodemgr docker-python
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-nodemgr", "--nodetype=contrail-config"]
LABEL net.juniper.nodemgr.filter.name=contrail-config-nodemgr
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
