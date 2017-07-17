FROM 10.87.64.33:5043/contrail-controller-config-base:4.0.1.0-23
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
RUN systemctl set-default multi-user.target
ENV init /lib/systemd/systemd
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["/usr/bin/python","/usr/bin/contrail-nodemgr","--nodetype=contrail-config"]
RUN yum install -y python-docker
CMD ["/lib/systemd/systemd","systemd.unit=multi-user.target"]
LABEL net.juniper.contrail=config
LABEL net.juniper.node=controller
