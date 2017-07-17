FROM centos:7.3.1611
COPY contrail.repo /etc/yum.repos.d/
RUN yum update -y
RUN yum install -y yum-plugin-priorities
RUN yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm
RUN yum install -y https://repos.fedorapeople.org/repos/openstack/openstack-newton/rdo-release-newton-5.noarch.rpm
RUN yum install -y contrail-lib contrail-nodemgr contrail-setup contrail-utils python-contrail contrail-config-openstack
RUN yum install -y iproute

CMD ["/usr/bin/tail","-f","/dev/null"]
