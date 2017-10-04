# vim:set ft=dockerfile:
FROM localhost:5000/contrail-base:4.0.1.0-32

# explicitly set user/group IDs
RUN groupadd -r cassandra && useradd -r -g cassandra cassandra

RUN echo $'[cassandra]\n\
[cassandra]\n\
name = Apache Cassandra repo\n\
baseurl = http://www.apache.org/dist/cassandra/redhat/22x\n\
enabled = 1\n\
gpgcheck = 0\n'\
>> /etc/yum.repos.d/cassandra.repo

ENV CASSANDRA_VERSION 2.2.10

RUN yum install -y cassandra-"$CASSANDRA_VERSION"

# https://issues.apache.org/jira/browse/CASSANDRA-11661
RUN sed -ri 's/^(JVM_PATCH_VERSION)=.*/\1=25/' /etc/cassandra/default.conf/cassandra-env.sh

ENV CASSANDRA_CONFIG /etc/cassandra/default.conf

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

RUN mkdir -p /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chown -R cassandra:cassandra /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chmod 777 /var/lib/cassandra "$CASSANDRA_CONFIG"
VOLUME /var/lib/cassandra

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160
CMD ["cassandra", "-f"]
