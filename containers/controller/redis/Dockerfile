FROM centos:7.3.1611

RUN yum install -y yum-plugin-priorities
RUN yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
RUN yum install -y redis iproute

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["redis-server","/etc/redis.conf"]
