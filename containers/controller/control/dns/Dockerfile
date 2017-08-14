FROM 10.87.64.33:5043/contrail-controller-control-base:4.0.0.0-20
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/contrail-dns"]
#CMD ["/usr/bin/contrail-dns","&&","/usr/bin/contrail-named","-f","-g","-u","contrail","-c","/etc/contrail/dns/contrail-named.conf"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
