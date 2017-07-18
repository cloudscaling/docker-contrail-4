FROM  10.87.64.33:5043/contrail-analytics-base:4.0.0.0-20
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-collector"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
