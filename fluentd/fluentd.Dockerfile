ARG FLUENTD_IMAGE_TAG=v1.18.0-debian-1

FROM fluent/fluentd:${FLUENTD_IMAGE_TAG}

USER root

ARG FLUENTD_APT_ADDITIONAL_PACKAGES
ARG FLUENTD_GEM_ADDITIONAL_PACKAGES

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential libmariadb-dev ${FLUENTD_APT_ADDITIONAL_PACKAGES} && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    gem install msgpack ${FLUENTD_GEM_ADDITIONAL_PACKAGES}

USER fluent
