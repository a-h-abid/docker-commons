@ECHO OFF

REM Copy docker compose example files
COPY .env.example .\.env
COPY docker-compose.override.example.yml .\docker-compose.override.yml

REM Create {name}.env files from .example.env files in .envs directory
COPY .envs\adminer.example.env .\.envs\adminer.env
COPY .envs\apache-druid.example.env .\.envs\apache-druid.env
COPY .envs\apache-zookeeper.example.env .\.envs\apache-zookeeper.env
COPY .envs\blackfire.example.env .\.envs\blackfire.env
COPY .envs\cassandra.example.env .\.envs\cassandra.env
COPY .envs\cassandra-dse.example.env .\.envs\cassandra-dse.env
COPY .envs\dragonfly.example.env .\.envs\dragonfly.env
COPY .envs\elasticsearch.example.env .\.envs\elasticsearch.env
COPY .envs\flagr.example.env .\.envs\flagr.env
COPY .envs\grafana.example.env .\.envs\grafana.env
COPY .envs\http-proxy.example.env .\.envs\http-proxy.env
COPY .envs\jaeger.example.env .\.envs\jaeger.env
COPY .envs\jenkins.example.env .\.envs\jenkins.env
COPY .envs\kibana.example.env .\.envs\kibana.env
COPY .envs\ldap.example.env .\.envs\ldap.env
COPY .envs\minio.example.env .\.envs\minio.env
COPY .envs\mongo.example.env .\.envs\mongo.env
COPY .envs\mysql.example.env .\.envs\mysql.env
COPY .envs\oracle.example.env .\.envs\oracle.env
COPY .envs\postgres.example.env .\.envs\postgres.env
COPY .envs\rabbitmq.example.env .\.envs\rabbitmq.env
COPY .envs\redis.example.env .\.envs\redis.env
COPY .envs\redis-commander.example.env .\.envs\redis-commander.env
COPY .envs\redis-sentinel.example.env .\.envs\redis-sentinel.env
COPY .envs\redis-slave.example.env .\.envs\redis-slave.env
COPY .envs\redis-stack.example.env .\.envs\redis-stack.env
COPY .envs\redisearch.example.env .\.envs\redisearch.env
COPY .envs\redisearch-slave.example.env .\.envs\redisearch-slave.env
COPY .envs\traefik.example.env .\.envs\traefik.env
COPY .envs\tz.example.env .\.envs\tz.env
