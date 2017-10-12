FROM centos:7.3.1611
ARG REPOSITORY=http://10.0.2.15/contrail
RUN printf "[contrail] \nname = Contrail repo \nbaseurl = $REPOSITORY \nenabled = 1 \ngpgcheck = 0\n" >> /etc/yum.repos.d/contrail.repo
RUN yum update -y
RUN yum install -y yum-plugin-priorities
RUN yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm
RUN yum install -y https://repos.fedorapeople.org/repos/openstack/openstack-newton/rdo-release-newton-5.noarch.rpm
RUN yum install -y contrail-lib contrail-nodemgr contrail-setup contrail-utils python-contrail
RUN yum install -y iproute

CMD ["/usr/bin/tail","-f","/dev/null"]
