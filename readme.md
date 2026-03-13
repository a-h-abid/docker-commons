# Docker Commons

A ready-to-use collection of common development services (databases, caches, queues, and more) managed through Docker Compose. Run all your shared services from one place instead of duplicating them across every project.

## Why This Project?

When working on multiple projects at the same time, each project often comes with its own set of services like MySQL, Redis, or RabbitMQ. Running duplicate copies of the same service wastes system resources and makes it hard to keep track of ports and configurations.

**Docker Commons solves this by letting you:**

- Run shared services (databases, caches, queues, etc.) once and connect any project to them.
- Pick only the services you need — no need to start everything.
- Use simple network aliases (e.g. `common-mysql`, `common-redis`) so your apps can find services easily.
- Keep all service settings in one place, making them easy to update.

Inspired by [LaraDock](https://github.com/laradock/laradock).


## Documentation

Each service that needs extra setup or has special instructions has its own documentation inside its folder. See the links in the [Services](#services) table below.

| Document | Description |
|----------|-------------|
| [Adminer Docs](adminer/readme.md) | Database management UI notes |
| [Cassandra DSE Docs](cassandra-dse/readme.md) | DataStax Enterprise configuration details |
| [Elasticsearch Docs](elasticsearch/readme.md) | Password setup, certificate generation |
| [Flagr Docs](flagr/readme.md) | Feature flag service overview |
| [MinIO Docs](minio/readme.md) | S3-compatible object storage notes |
| [MySQL Docs](mysql/readme.md) | MySQL references and links |
| [MySQL Slave Docs](mysql-slave/readme.md) | MySQL replication setup |
| [NFS Server Docs](nfs-server/readme.md) | NFS mount/unmount instructions |
| [Volume Backup & Restore Docs](volumes-bnr/readme.md) | Backup and restore Docker volumes |


## Services

Below is the full list of services included in this project. The **Compose Name** is what you use in `docker compose up -d <name>` commands. The **Network Alias** is the hostname your application uses to connect to the service.

| Name | Compose Name | Description | Docs | Build Required | Network Alias |
|------|-------------|-------------|------|:--------------:|---------------|
| Adminer | adminer | Web UI for managing databases (MySQL, Postgres, Mongo, etc.) | [Docs](adminer/readme.md) | | |
| Apache Druid | apache_druid_* | Real-time analytics database (coordinator, broker, historical, middlemanager, router) | | | |
| Apache Zookeeper | zookeeper | Distributed coordination service for Apache Druid and others | | | |
| Blackfire | blackfire | PHP performance profiling and monitoring tool | | | common-blackfire |
| Cassandra | cassandra | Distributed NoSQL database for large-scale data | | | common-cassandra |
| Cassandra DSE | cassandra-node1/2/3 | DataStax Enterprise Cassandra multi-node cluster | [Docs](cassandra-dse/readme.md) | Yes | |
| Dragonflydb | dragonfly | High-performance in-memory datastore, drop-in Redis replacement | | | common-dragonfly |
| Elasticsearch | elasticsearch | Search and analytics engine for log analysis, full-text search, and more | [Docs](elasticsearch/readme.md) | Yes | common-elasticsearch |
| Flagr | flagr | Feature flagging and A/B testing microservice | [Docs](flagr/readme.md) | Yes | common-flagr |
| Fluentd | fluentd | Log collector and aggregator | | Yes | |
| Grafana | grafana | Metrics visualization and monitoring dashboards | | | |
| Jaeger | jaeger | Distributed tracing for monitoring microservices | | | common-jaeger |
| Jenkins | jenkins | CI/CD automation server | | | common-jenkins |
| Kibana | kibana | Visualization dashboard for Elasticsearch data | | Yes | |
| MailDev | maildev | Email testing tool — catches outgoing emails for inspection | | | common-maildev |
| Mailhog | mailhog | SMTP testing server with a web UI to view caught emails | | | common-mailhog |
| MinIO | minio | S3-compatible object storage | [Docs](minio/readme.md) | | common-minio |
| MinIO Client (MC) | minio-client | CLI tool for managing MinIO buckets and objects | | | |
| MinIO Nginx | minio-nginx | Reverse proxy for MinIO API and console | | | |
| MongoDB | mongo | NoSQL document database | | | common-mongo |
| MySQL | mysql | Popular relational database | [Docs](mysql/readme.md) | | common-mysql |
| NFS Server | nfs-server | Simple NFS file server for local testing | [Docs](nfs-server/readme.md) | | |
| OpenLDAP | ldap | Lightweight directory access protocol server | | | common-ldap |
| Oracle XE | oracle | Oracle Express Edition database | | Yes | common-oracle |
| Portainer | portainer | Web UI for managing Docker containers and images | | | |
| PostgreSQL | postgres | Advanced open-source relational database | | | common-postgres |
| RabbitMQ | rabbitmq | Message broker for queuing and async communication | | | common-rabbitmq |
| Redis | redis | In-memory data store used for caching and sessions | | | common-redis |
| Redis Commander | redis-commander | Web UI for browsing Redis data | | | |
| Redis Sentinel | redis-sentinel | High-availability monitor for Redis | | | common-redis-sentinel |
| Redis Stack | redis-stack | Redis with built-in search, JSON, and time-series modules | | | |
| RediSearch | redisearch | Redis with full-text search capabilities | | Yes | common-redisearch |
| SFTP | sftp | Secure file transfer server | | | common-sftp |
| Traefik | traefik | Reverse proxy and load balancer for routing HTTP traffic | | | traefik |
| Volume Backup | volume-backup | Utility to back up Docker named volumes | [Docs](volumes-bnr/readme.md) | | |
| Volume Restore | volume-restore | Utility to restore Docker named volumes | [Docs](volumes-bnr/readme.md) | | |

### Special Notes

- **Elasticsearch & Kibana** — Require a custom image build. On first start, Elasticsearch generates a password you will need. See [Elasticsearch Docs](elasticsearch/readme.md) for details.
- **Cassandra DSE** — Runs as a multi-node cluster (3 nodes). Default credentials are `cassandra` / `cassandra`. See [Cassandra DSE Docs](cassandra-dse/readme.md).
- **NFS Server** — After starting, you must mount the NFS share on your host. See [Service Specific Details](#nfs-server) below for commands.
- **Apache Druid** — Requires Apache Zookeeper to be running. Start both together: `docker compose up -d zookeeper apache_druid_coordinator apache_druid_broker apache_druid_historical apache_druid_middlemanager apache_druid_router`.


## Operating System Notes

### Linux

- Fully supported. All services work natively.
- Use `copy-examples.sh` to create configuration files.
- Use `:` as the path separator in the `.env` file for `COMPOSE_PATH_SEPARATOR`.

### macOS

- Supported. Use `bash copy-examples.sh` to create configuration files.
- Use `:` as the path separator in the `.env` file for `COMPOSE_PATH_SEPARATOR`.

### Windows

- Use `copy-examples.bat` to create configuration files.
- Use `;` as the path separator in the `.env` file for `COMPOSE_PATH_SEPARATOR`.
- **If your system supports WSL2, it is highly recommended to use that instead** of running Docker directly on Windows.
- The following services **do not work** on a Windows host and require WSL2:
    - NFS Server


## Tested Docker Version

- Docker Engine v20.10+ / Docker Desktop v4.0+
- Docker Compose v2.7+ (Use `docker compose` command)
    - or v1.29+ (Use `docker-compose` command)


## Quick Start

A `Makefile` is provided so you can manage everything with short commands. Run `make help` to see all available targets.

```bash
git clone https://github.com/a-h-abid/docker-commons.git
cd docker-commons

make setup                        # Copy config files & create Docker networks
# Edit .env and .envs/*.env to taste
make pull                         # Pull service images
make up SERVICES="mysql redis"    # Start only what you need
```

| Command | What it does |
|---------|-------------|
| `make setup` | Copy example configs and create Docker networks |
| `make up` | Start all configured services |
| `make up SERVICES="mysql redis"` | Start specific services only |
| `make down` | Stop and remove all services |
| `make stop SERVICES="redis"` | Stop specific services |
| `make restart` | Restart services |
| `make ps` | Show running services |
| `make logs SERVICES="mysql"` | Follow service logs |
| `make pull` | Pull latest images |
| `make build SERVICES="elasticsearch"` | Build custom images |
| `make validate` | Validate compose files |
| `make list` | List all available services |
| `make clean` | Stop everything, remove volumes and networks |
| `make help` | Show all commands |


## Setup Process (Manual)

If you prefer not to use `make`, follow these manual steps:

1. Open a terminal or command prompt.
1. Clone this repository and `cd` into the directory. Opening it in an IDE is helpful.
1. Create configuration files from the provided examples. Run the appropriate script for your OS (see [Operating System Notes](#operating-system-notes) above), or copy the files manually. **Do not delete the example files** — they are kept for reference.
    * `.env.example` → `.env`
    * `docker-compose.override.example.yml` → `docker-compose.override.yml`
    * `.envs/{name}.example.env` → `.envs/{name}.env`
1. Edit `.env` and update values for your environment:
    * `COMPOSE_FILE` — List the `docker-compose.override.{name}.yml` files for the services you want. Keep `docker-compose.override.yml` at the end.
    * `COMPOSE_PATH_SEPARATOR` — Use `:` on Linux/macOS or `;` on Windows.
    * Other settings are documented as comments inside the file.
1. Edit `docker-compose.override.yml`:
    * Remove service sections you do not need.
    * Adjust any settings as required.
1. Edit files in `.envs/{name}.env` as needed for each service.
1. Pull the Docker images:
    ```bash
    docker compose pull
    ```
    If it stops due to a network error, just run it again.
1. Create the shared Docker network:
    ```bash
    docker network create common-net
    ```
1. *(Optional)* If using Traefik, create its network:
    ```bash
    docker network create common-traefik-net
    ```
1. *(Optional)* If using services that require a custom image build (see the [Services](#services) table), build them:
    ```bash
    docker compose build <service-name>
    ```


## Running Services

* Start all services:
    ```bash
    make up            # or: docker compose up -d
    ```
* Start specific services only:
    ```bash
    make up SERVICES="adminer mysql"   # or: docker compose up -d adminer mysql
    ```


## Checking Services Status

* View running services:
    ```bash
    make ps            # or: docker compose ps
    ```
* View logs for a specific service:
    ```bash
    make logs SERVICES="mysql"         # or: docker compose logs --tail=100 mysql
    ```


## Stopping Services

* Stop all services:
    ```bash
    make down          # or: docker compose down
    ```
* Stop specific services only:
    ```bash
    make stop SERVICES="adminer mysql" # or: docker compose rm -sf adminer mysql
    ```


## General Usage in Applications

Connect your application's Docker network to `common-net` and use the service's **network alias** as the hostname and the **container port** as the port number.

For example, to connect to MySQL, add this to your application's `docker-compose.yml`:

```yaml
networks:
  common-net:
    external: true

services:
  myapp:
    ...
    networks:
      - common-net
      ...
```

Then in your application's database configuration:
* Host: `common-mysql`
* Port: `3306`

Restart your application container and it will be able to reach MySQL. This same approach works for all services that have a network alias.


## Service Specific Details

### NFS Server

After starting the NFS container, mount it on your host machine. First find the container's IP (e.g. using `ifconfig` or `hostname -I`), then run:

```bash
sudo mount -v -o vers=4,loud <container-ip>:/ /path/to/mount
```

**Important:** Always unmount before shutting down your machine to avoid issues:

```bash
sudo umount /path/to/mount
```


## FAQ

### Can I run this in production?

This project is designed for **local development**. It can be adapted for production, but you may need to change security settings, use different images, or mount custom configuration files. Always review security concerns before deploying any of these services in a production environment.


## Future Plans

* Make it work with **Podman**.


## License

This project is licensed under the terms of the [MIT License](LICENSE).
