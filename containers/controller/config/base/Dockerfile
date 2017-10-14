FROM centos:7.3.1611

#ARG REPO_URL=http://192.168.56.30/contrail
#RUN printf "[contrail] \nname = Contrail repo \nbaseurl = $REPO_URL \nenabled = 1 \ngpgcheck = 0\n" >> /etc/yum.repos.d/contrail.repo

COPY contrail.repo /etc/yum.repos.d/contrail.repo

RUN yum update -y; \
    yum install -y yum-plugin-priorities iproute telnet \
                   http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm \
                   https://repos.fedorapeople.org/repos/openstack/openstack-newton/rdo-release-newton-5.noarch.rpm ; \
    yum install -y contrail-lib contrail-nodemgr contrail-setup contrail-utils python-contrail contrail-config contrail-config-openstack;

CMD ["/usr/bin/tail","-f","/dev/null"]
