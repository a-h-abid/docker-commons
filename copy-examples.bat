@ECHO OFF

REM Copy docker compose example files
COPY .env.example .\.env
COPY docker-compose.override.example.yml .\docker-compose.override.yml

REM Create {name}.env files from .example.env files in .envs directory
COPY .envs\adminer.example.env .\.envs\adminer.env
COPY .envs\cassandra.example.env .\.envs\cassandra.env
COPY .envs\elasticsearch.example.env .\.envs\elasticsearch.env
COPY .envs\grafana.example.env .\.envs\grafana.env
COPY .envs\http-proxy.example.env .\.envs\http-proxy.env
COPY .envs\kibana.example.env .\.envs\kibana.env
COPY .envs\ldap.example.env .\.envs\ldap.env
COPY .envs\minio.example.env .\.envs\minio.env
COPY .envs\mysql.example.env .\.envs\mysql.env
COPY .envs\oracle.example.env .\.envs\oracle.env
COPY .envs\rabbitmq.example.env .\.envs\rabbitmq.env
COPY .envs\redis-commander.example.env .\.envs\redis-commander.env
COPY .envs\redis-sentinel.example.env .\.envs\redis-sentinel.env
COPY .envs\redis-slave.example.env .\.envs\redis-slave.env
COPY .envs\redis.example.env .\.envs\redis.env
COPY .envs\traefik.example.env .\.envs\traefik.env
COPY .envs\tz.example.env .\.envs\tz.env
