ARG REDISEARCH_IMAGE_TAG="2.0.6"
ARG REDIS_IMAGE_TAG="6.0.10"

FROM redislabs/redisearch:${REDISEARCH_IMAGE_TAG} as builder

FROM bitnami/redis:${REDIS_IMAGE_TAG}

LABEL maintainer="Raonak Islam <raonak92@gmail.com>"

ENV LIBDIR /usr/lib/redis/modules/

USER  root

RUN mkdir -p "$LIBDIR";

COPY --from=builder /usr/lib/redis/modules/redisearch.so*  "$LIBDIR"

USER 1001

CMD [ "/opt/bitnami/scripts/redis/run.sh", "--loadmodule", "/usr/lib/redis/modules/redisearch.so" ]
