FROM localhost:5000/contrail-controller-control-base:4.0.1.0-32
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-control"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
