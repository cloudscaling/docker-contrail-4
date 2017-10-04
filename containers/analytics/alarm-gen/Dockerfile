FROM  localhost:5000/contrail-analytics-base:4.0.1.0-32
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/python","/usr/bin/contrail-alarm-gen","-c","/etc/contrail/contrail-alarm-gen.conf"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
