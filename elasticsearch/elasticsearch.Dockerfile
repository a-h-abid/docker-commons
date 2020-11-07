ARG EK_IMAGE_TAG=7.9.3

FROM docker.elastic.co/elasticsearch/elasticsearch:${EK_IMAGE_TAG}

ARG ELASTICSEARCH_CERTS_DIR=/usr/share/elasticsearch/config/certificates

LABEL maintainer="Proshanta Barman <proshanta@brainstation-23.com>"

COPY ./commons/certs ${ELASTICSEARCH_CERTS_DIR}
