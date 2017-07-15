FROM contrail-controller-config-base:4.0.0.0-20
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
RUN yum install -y nodejs-0.10.35-1contrail.el7 contrail-openstack-webui
WORKDIR /usr/src/contrail/contrail-web-core
CMD ["/usr/bin/node","webServerStart.js"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
