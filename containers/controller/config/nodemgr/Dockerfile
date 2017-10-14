ARG CONTRAIL_VERSION=4.0.1.0-32
ARG CONTRAIL_REGISTRY=localhost:5000
FROM ${CONTRAIL_REGISTRY}/contrail-controller-config-base:${CONTRAIL_VERSION}
COPY entrypoint.sh /
RUN yum install -y contrail-nodemgr docker-python
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python", "/usr/bin/contrail-nodemgr", "--nodetype=contrail-config"]
LABEL net.juniper.nodemgr.filter.name=contrail-config-nodemgr
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
