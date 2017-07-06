FROM contrail-quagga-base:4.0.0.0-20
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/ospfd","-f","/etc/quagga/ospf.conf","-i","/etc/quagga/ospf.pid","-z","/etc/quagga/zebra.socket"]
