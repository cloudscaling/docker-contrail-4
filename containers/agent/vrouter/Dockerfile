FROM  localhost:5000/contrail-agent-base:4.0.1.0-32
RUN yum install -y contrail-vrouter-agent contrail-vrouter contrail-vrouter-init contrail-k8s-cni
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-vrouter-agent"]
LABEL net.juniper.contrail=agent
LABEL net.juniper.node=agent

