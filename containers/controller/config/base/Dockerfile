FROM centos:7.3.1611
ARG REPO_URL=http://10.87.64.32/contrail-4.0.0.0-20
RUN printf "[contrail] \nname = Contrail repo \nbaseurl = $REPO_URL \nenabled = 1 \ngpgcheck = 0\n" >> /etc/yum.repos.d/contrail.repo
#RUN echo $'[contrail]\n\
#name = Contrail repo\n\
#baseurl = $REPO_URL\n\
#enabled = 1\n\
#gpgcheck = 0\n'\
#>> /etc/yum.repos.d/contrail.repo
RUN yum update -y
RUN yum install -y yum-plugin-priorities
RUN yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm
RUN yum install -y https://repos.fedorapeople.org/repos/openstack/openstack-newton/rdo-release-newton-5.noarch.rpm
RUN yum install -y contrail-lib contrail-nodemgr contrail-setup contrail-utils python-contrail contrail-config-openstack iproute

CMD ["/usr/bin/tail","-f","/dev/null"]
