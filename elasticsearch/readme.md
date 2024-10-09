# ElasticSearch

Elasticsearch is commonly used for log analytics, full-text search, security intelligence, business analytics, and operational intelligence use cases.

## Usage

*P.S.* Usage approach may change in different version. Do check updated process here: [Install Elastic with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)

1. When starting the elasticsearch container for first time, view the log to get the elastic password that it auto generates. We store this password in the env `ELASTIC_PASSWORD`. If need to regenerate, run: `docker compose exec elasticsearch /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic`
1. For kibana, run: `docker compose exec elasticsearch /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic`







bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip;
unzip config/certs/ca.zip -d config/certs;


echo -ne \
"instances:\n"\
"  - name: elasticsearch\n"\
"    dns:\n"\
"      - elasticsearch\n"\
"      - common-elasticsearch\n"\
"      - localhost\n"\
"    ip:\n"\
"      - 127.0.0.1\n"\
> config/certs/instances.yml;

bin/elasticsearch-certutil cert --silent --pem -out config/certs/certs.zip --in config/certs/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key;
unzip config/certs/certs.zip -d config/certs;



