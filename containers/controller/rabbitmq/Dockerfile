FROM centos:7.3.1611

ENV RABBITMQ_VERSION 3.6.10-1
ENV RABBITMQ_CENTOS_VERSION 3.6.10-1

RUN rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
RUN yum install -y yum-plugin-priorities
RUN yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
RUN yum install -y erlang
RUN yum install -y https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_10/rabbitmq-server-3.6.10-1.el7.noarch.rpm
RUN yum install -y iproute
RUN yum install -y bind-utils

ENV PATH /usr/lib/rabbitmq/bin:$PATH
ENV HOME /var/lib/rabbitmq

RUN mkdir -p /var/lib/rabbitmq /etc/rabbitmq \
    && chown -R rabbitmq:rabbitmq /var/lib/rabbitmq /etc/rabbitmq \
    && chmod -R 777 /var/lib/rabbitmq /etc/rabbitmq
VOLUME /var/lib/rabbitmq

RUN ln -sf /var/lib/rabbitmq/.erlang.cookie /root/
RUN ln -sf /usr/lib/rabbitmq/lib/rabbitmq_server-$RABBITMQ_VERSION/plugins /plugins


COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/lib/rabbitmq/bin/rabbitmq-server"]
#CMD ["rabbitmq-server"]
