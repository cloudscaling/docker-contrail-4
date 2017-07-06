FROM contrail-quagga-base:4.0.0.0-20
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/zebra","-f","/etc/quagga/zebra.conf","-i","/etc/quagga/zebra.pid","-z","/etc/quagga/zebra.socket"]
