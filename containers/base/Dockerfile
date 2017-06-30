FROM centos:7.3.1611
COPY contrail.repo /etc/yum.repos.d/
RUN yum update -y
RUN yum install -y yum-plugin-priorities
RUN yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
RUN yum install -y https://repos.fedorapeople.org/repos/openstack/openstack-newton/rdo-release-newton-5.noarch.rpm
RUN curl -o /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64
RUN chmod +x /usr/bin/confd
RUN mkdir -p /etc/confd/{conf.d,templates}
RUN yum install -y iproute

CMD ["/usr/bin/tail","-f","/dev/null"]
