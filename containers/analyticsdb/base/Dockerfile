FROM centos:7.3.1611
RUN yum update -y
RUN yum install -y yum-plugin-priorities
RUN yum install -y iproute

CMD ["/usr/bin/tail","-f","/dev/null"]
