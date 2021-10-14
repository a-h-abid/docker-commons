# Docker Commons

This is a personal project which consists some common services configured to run via docker scripts to use centrally for applications in local development.

The problem this project solves is that during development in multiple projects, sometime they have their own services (MySQL, Redis, etc.) which already takes lots of resources by itself and having to run same services multiple times for multiple projects is too much for your system. Also most of the time those services configurations & versions are not much different in each project. Or those differences might not matter to you. Also keeping up with remembering all the publish ports of these services can be quite difficult.

As these things became a problem for me, I made this docker script to easily manage them centrally from one place. Also made it configurable to run only those services you need.


## Services

Name                | In Compose      | Require Image Build
--------------------|-----------------|--------------------
Adminer             | adminer         | No
Cassandra           | mysql           | No
ElasticSearch       | elasticsearch   | Yes
Grafana             | grafana         | No
Kibana              | kibana          | Yes
Mailhog             | mailhog         | No
MinIO               | minio           | No
MinIO Client (MC)   | minio-client    | No
MySQL               | mysql           | No
NFS Server          | nfs-server      | No
OpenLDAP            | ldap            | No
Oracle              | oracle          | Yes
RabbitMQ            | rabbitmq        | No
Redis               | redis           | No
Redis Commander     | redis-commander | No
Redis Sentinel      | redis-sentinel  | No
RediSearch          | redisearch      | No
Traefik             | traefik         | No
Volume Backup       | volume-backup   | No
Volume Restore      | volume-restore  | No


## Tested Docker Version

- Docker Engine v20.13+
- Docker Compose v1.27+


## Setup Process

1. Clone the project to a path and `cd` to it.
1. Copy `./.env.example` file to `./.env` and then you will have to update the values per your need.
  * In `COMPOSE_FILE` env for the services you want to use.
1. Copy `./docker-compose.override.example.yml` file to `./docker-compose.override.yml` and then update it with components as per your need.
1. Copy all example files in `./envs` to `./envs/{service-name}.env` file and then update them per your need.
  * Ex. `cp ./.envs/mysql.example.env ./.envs/mysql.env`.
1. Run `docker network create common-net`


## Running Services

* Run all services quickly by `docker-compose up -d` or...
* Run specific services only by `docker-compose up -d <service1> <service2> ...`


## NFS server after up

Mount nfs server in your host machine. To get container IP, you can use `ifconfig` or `hostname -I` or any other method you know.

```
sudo mount -v -o vers=4,loud <container-ip>:/ /path/to/mount
```

**Important:** In your development machine, be sure to unmount the path, otherwise may cause issues. To unmount:

```
sudo umount /path/to/mount
```

## License

This project is licensed under the terms of the MIT license.
