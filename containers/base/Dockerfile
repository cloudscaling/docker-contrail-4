FROM centos:7.3.1611
ARG REPO_URL=http://10.0.2.15/contrail
RUN printf "[contrail] \nname = Contrail repo \nbaseurl = $REPO_URL \nenabled = 1 \ngpgcheck = 0\n" >> /etc/yum.repos.d/contrail.repo
RUN yum update -y
RUN yum install -y yum-plugin-priorities
RUN yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm
RUN yum install -y iproute

CMD ["/usr/bin/tail","-f","/dev/null"]
