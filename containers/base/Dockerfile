FROM centos:7.3.1611
COPY contrail.repo /etc/yum.repos.d/
RUN yum update -y
RUN yum install -y yum-plugin-priorities
RUN yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm
RUN yum install -y iproute less

CMD ["/usr/bin/tail","-f","/dev/null"]
