#!/usr/bin/env bash

set -e

cp --update=none .example.env .env
cp --update=none compose.elasticsearch.example.yaml compose.elasticsearch.yaml

COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-common}

if [ ! -f certs/instances.yml ]; then
  echo -ne \
  "instances:\n"\
  "  - name: elasticsearch\n"\
  "    dns:\n"\
  "      - elasticsearch\n"\
  "      - common-elasticsearch\n"\
  "      - localhost\n"\
  "    ip:\n"\
  "      - 127.0.0.1\n"\
  > certs/instances.yml
fi

if [ ! -f certs/ca.zip ]; then
  docker compose -f compose.elasticsearch.yaml -f ../compose.networks.yaml run --rm elasticsearch bash -c 'bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip && unzip -q config/certs/ca.zip -d config/certs'
  echo 'ElasticSearch: CA Files Created!'
fi

if [ ! -f certs/certs.zip ]; then
  docker compose -f compose.elasticsearch.yaml -f ../compose.networks.yaml run --rm elasticsearch bash -c 'bin/elasticsearch-certutil cert --silent --pem -out config/certs/certs.zip --in config/certs/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key && unzip -q config/certs/certs.zip -d config/certs'
  echo 'ElasticSearch: Cert Files Created!'
fi

echo 'ElasticSearch: Ready to start!!!'
