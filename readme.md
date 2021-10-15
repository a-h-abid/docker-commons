# Docker Commons

This is a personal project which consists some common services configured to run via docker scripts to use centrally for applications in local development.

The problem this project solves is that during development in multiple projects, sometime they have their own services (MySQL, Redis, etc.) which already takes lots of resources by itself and having to run same services multiple times for multiple projects is too much for your system. Also most of the time those services configurations & versions are not much different in each project. Or those differences might not matter to you. Also keeping up with remembering all the publish ports of these services can be quite difficult.

As these things became a problem for me, I made this docker script to easily manage them centrally from one place. Also made it configurable to run only those services you need.

I have tested it mostly in a Linux environment, but I also tried to add some support for Windows OS. If your Windows OS supports WSL2, I highly encourage you to use that.


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

**Note**: The following services will not work in Windows Host Machine. You will have to use it inside WSL2 Distribution.
* NFS Server


## Tested Docker Version

- Docker Engine v20.10+
- Docker Compose v1.27+


## Setup Process

1. Open a terminal or command prompt.
1. Git clone the project to a path and `cd` to it. If possible open the directory in an IDE.
1. You will have to create files from example files. You can simply run the `copy-examples.sh` (Linux) / `copy-examples.bat` (Windows) file to auto-create them or create them manually as below by copying them. Special note: **DO NOT DELETE EXAMPLE FILES**. These are kept for reference.
    * .env.example -> .env
    * docker-compose.override.example.yml -> docker-compose.override.yml
    * .envs/{name}.example.env -> .envs/{name}.env
1. In file `./.env`, you will have to update the values per your need.
    * `COMPOSE_FILE`: Mention the `docker-compose.override.{name}.yml` files you will want to use. Keep the `docker-compose.override.yml` file at the end. Use separator `:` for Linux or `;` for Windows.
    * `COMPOSE_PATH_SEPARATOR`: Use separator `:` for Linux or `;` for Windows.
    * Rest details are written in the file as comments. Read and do update as you need.
1. In file `./docker-compose.override.yml`, you will have to update the values per your need.
    * Remove any service sections you will not use.
    * Modify any settings you want to add or remove as you need.
1. Files in `.envs/{name}.env`, update them as you need.
1. Run `docker network create common-net`. We will use this network to connect internally from our applications.
1. (Optional) If you want to use Traefik, run `docker network create common-traefik-net`. We will use this network to serve web requests using domain names to our application's web server.


## Running Services

* Run all services quickly by `docker-compose up -d` or...
* Run specific services only by `docker-compose up -d <service1> <service2> ...`


## Service Specific Details

### NFS server

After starting the container, you have to mount nfs server in your host machine. To get container IP, you can use `ifconfig` or `hostname -I` or any other method you know.

```
sudo mount -v -o vers=4,loud <container-ip>:/ /path/to/mount
```

**Important:** In your development machine, be sure to unmount the path, otherwise may cause issues. To unmount:

```
sudo umount /path/to/mount
```

## License

This project is licensed under the terms of the MIT license.
