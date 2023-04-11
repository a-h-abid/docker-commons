ARG DSE_SERVER_VERSION=6.8.16-ubi7

FROM datastax/dse-server:${DSE_SERVER_VERSION}

LABEL maintainer="Md. Nazmus Saqib Khan <ratulkhan.jhenidah@gmail.com>"

# Copy the configuration files into the container
COPY ./cassandra-dse/cassandra.yaml /opt/dse/resources/cassandra/conf/cassandra.yaml
COPY ./cassandra-dse/dse.yaml /opt/dse/resources/dse/conf/dse.yaml

# Exposing ports for inter cluster communication
# Intra-node communication: PORT 700
# TLS intra-node communication: PORT 7001
# JMX: PORT 7199
# CQL: PORT 9042
# CQL SSL: PORT 9142
EXPOSE 7000 7001 7199 9042 9142

# Set the working directory
WORKDIR /opt/dse