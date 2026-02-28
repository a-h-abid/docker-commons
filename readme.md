# Docker Commons

[![Validate](https://github.com/a-h-abid/docker-commons/actions/workflows/validate.yml/badge.svg)](https://github.com/a-h-abid/docker-commons/actions/workflows/validate.yml)

A collection of common development services (MySQL, Redis, PostgreSQL, RabbitMQ, etc.) configured to run centrally via Docker Compose. Share services across multiple projects without running duplicate instances.

## 🎯 Why Docker Commons?

**The Problem:** During development across multiple projects, each project often includes its own services (MySQL, Redis, etc.). This:
- Consumes excessive system resources (RAM, CPU)
- Creates port conflicts
- Makes it hard to remember which ports are used where
- Results in duplicate configurations and data

**The Solution:** Docker Commons provides a centralized, configurable setup where:
- Services run once and are shared across projects
- Consistent network naming (`common-net`) simplifies connections
- Easy configuration with example files
- Choose only the services you need

**Inspired by:** [LaraDock](https://github.com/laradock/laradock)

## 📚 Documentation

- **[Quick Start Guide](QUICKSTART.md)** - Get started in 5 minutes
- **[Troubleshooting Guide](TROUBLESHOOTING.md)** - Solutions to common issues
- **[Contributing Guide](CONTRIBUTING.md)** - How to contribute
- **[Security Policy](SECURITY.md)** - Security considerations and best practices

## ⚡ Quick Start

```bash
# Clone and setup
git clone https://github.com/a-h-abid/docker-commons.git
cd docker-commons
./copy-examples.sh  # or copy-examples.bat on Windows

# Create networks
docker network create common-net

# Start services
docker compose up -d mysql redis adminer
```

See [QUICKSTART.md](QUICKSTART.md) for detailed instructions.

## 🖥️ Platform Support

**Fully Tested:**
- Linux (Ubuntu, Debian, Fedora, etc.)
- macOS
- Windows with WSL2

**Note:** Some services (like NFS Server) require WSL2 on Windows.


## 📦 Available Services

### Databases

| Name | In Compose | Build Required | Network Alias | Default Port |
|------|------------|----------------|---------------|--------------|
| MySQL | mysql | No | common-mysql | 3306 |
| PostgreSQL | postgres | No | common-postgres | 5432 |
| MongoDB | mongo | No | common-mongo | 27017 |
| Cassandra | cassandra | No | common-cassandra | 9042 |
| Oracle | oracle | Yes | common-oracle | 1521 |

### Caching & Message Queues

| Name | In Compose | Build Required | Network Alias | Default Port |
|------|------------|----------------|---------------|--------------|
| Redis | redis | No | common-redis | 6379 |
| Redis Sentinel | redis-sentinel | No | common-redis-sentinel | 26379 |
| Redis Stack | redis-stack | No | - | 16479 |
| RediSearch | redisearch | Yes | common-redisearch | 16379 |
| Dragonfly | dragonfly | No | common-dragonfly | 36379 |
| RabbitMQ | rabbitmq | No | common-rabbitmq | 5672, 15672 |

### Search & Analytics

| Name | In Compose | Build Required | Network Alias | Default Port |
|------|------------|----------------|---------------|--------------|
| Elasticsearch | elasticsearch | Yes | common-elasticsearch | 9200 |
| Kibana | kibana | Yes | - | 5601 |

### Development Tools

| Name | In Compose | Build Required | Network Alias | Default Port |
|------|------------|----------------|---------------|--------------|
| Adminer | adminer | No | - | 8000 |
| Redis Commander | redis-commander | No | - | 8081 |
| MailHog | mailhog | No | common-mailhog | 1025, 8025 |
| MailDev | maildev | No | common-maildev | 1080 |
| Portainer | portainer | No | - | 9443 |

### Storage & Networking

| Name | In Compose | Build Required | Network Alias | Default Port |
|------|------------|----------------|---------------|--------------|
| MinIO | minio | No | common-minio | 9000, 9001 |
| MinIO Client (MC) | minio-client | No | - | - |
| SFTP | sftp | No | common-sftp | 8422 |
| NFS Server* | nfs-server | No | - | 2049 |
| Traefik | traefik | No | traefik | 80, 443 |

### Observability

| Name | In Compose | Build Required | Network Alias | Default Port |
|------|------------|----------------|---------------|--------------|
| Grafana | grafana | No | - | 3000 |
| Jaeger | jaeger | No | common-jaeger | 16686 |
| Fluentd | fluentd | No | - | 24224 |

### Other Services

| Name | In Compose | Build Required | Network Alias | Default Port |
|------|------------|----------------|---------------|--------------|
| OpenLDAP | ldap | No | common-ldap | - |
| Jenkins | jenkins | No | common-jenkins | 8443 |
| Blackfire | blackfire | No | common-blackfire | 32768 |
| Flagr | flagr | Yes | common-flagr | 28000 |
| Apache Zookeeper | zookeeper | No | - | 2181 |
| Apache Druid | apache_druid_* | No | - | Various |

### Utilities

| Name | In Compose | Build Required | Description |
|------|------------|----------------|-------------|
| Volume Backup | volume-backup | No | Backup named volumes |
| Volume Restore | volume-restore | No | Restore named volumes |

**\* Note:** NFS Server requires WSL2 on Windows.


## 🔧 Requirements

- **Docker Engine** v20.10+ or **Docker Desktop** v4.0+
- **Docker Compose** v2.7+ (command: `docker compose`)
  - Or Docker Compose v1.29+ (command: `docker-compose`)
- Git (for cloning)

## 🚀 Setup Process

### Step 1: Clone Repository
```bash
git clone https://github.com/a-h-abid/docker-commons.git
cd docker-commons
```

### Step 2: Copy Example Files

**Option A - Automated (Recommended):**
```bash
./copy-examples.sh  # Linux/macOS
copy-examples.bat   # Windows
```

**Option B - Manual:**
Create the following files from their `.example` versions:
- `.env.example` → `.env`
- `docker-compose.override.example.yml` → `docker-compose.override.yml`
- `.envs/{name}.example.env` → `.envs/{name}.env`

**⚠️ Important:** Do NOT delete example files. They are kept for reference.

### Step 3: Configure Services

**Edit `.env` file:**
- `COMPOSE_FILE`: List the services you want to use
  - Keep `docker-compose.override.yml` at the end
  - Use `:` separator on Linux/macOS, `;` on Windows
- `COMPOSE_PATH_SEPARATOR`: `:` for Linux/macOS, `;` for Windows
- Review other variables and adjust as needed

**Edit `docker-compose.override.yml`:**
- Remove service sections you don't need
- Customize ports, volumes, or other settings

**Edit `.envs/{service}.env` files:**
- Update credentials and service-specific settings

### Step 4: Pull Images
```bash
docker compose pull
```

If downloads fail due to network errors, re-run the command.

### Step 5: Create Networks
```bash
docker network create common-net
docker network create common-traefik-net  # Optional, for Traefik
```

### Step 6: Build Images (If Required)

Some services require building:
```bash
docker compose build elasticsearch  # Example
docker compose build kibana
docker compose build flagr
# etc.
```

### Step 7: Validate Configuration
```bash
# Validate Docker Compose files
docker compose config

# Or use the validation script
chmod +x validate.sh
./validate.sh
```

### Step 8: Start Services
```bash
# Start all configured services
docker compose up -d

# Or start specific services only
docker compose up -d mysql redis adminer
```


## 🎮 Managing Services

### Starting Services
```bash
# Start all configured services
docker compose up -d

# Start specific services
docker compose up -d adminer mysql redis
```

### Checking Status
```bash
# List all services and their status
docker compose ps

# View logs
docker compose logs --tail=100 <service-name>

# Follow logs in real-time
docker compose logs -f mysql
```

### Stopping Services
```bash
# Stop all services
docker compose down

# Stop specific services
docker compose rm -sf mysql redis

# Stop and remove volumes (⚠️ deletes data!)
docker compose down -v
```

### Restarting Services
```bash
# Restart specific service
docker compose restart mysql

# Recreate service with new configuration
docker compose up -d --force-recreate mysql
```


## 🔗 Connecting Your Applications

### Overview

Connect your application to Docker Commons services by:
1. Adding your application to the `common-net` network
2. Using service network aliases as hostnames
3. Using container ports (not published ports)

### Example: Connecting to MySQL

**Your application's `docker-compose.yml`:**
```yaml
networks:
  common-net:
    external: true

services:
  myapp:
    # ... your service configuration ...
    networks:
      - common-net
    environment:
      DB_HOST: common-mysql
      DB_PORT: 3306
      DB_DATABASE: mydb
      DB_USERNAME: root
      DB_PASSWORD: secret
```

### Connection Details by Service

| Service | Network Alias | Port | Example Connection String |
|---------|---------------|------|---------------------------|
| MySQL | `common-mysql` | 3306 | `mysql://root:pass@common-mysql:3306/dbname` |
| PostgreSQL | `common-postgres` | 5432 | `postgresql://user:pass@common-postgres:5432/dbname` |
| Redis | `common-redis` | 6379 | `redis://common-redis:6379` |
| MongoDB | `common-mongo` | 27017 | `mongodb://common-mongo:27017/dbname` |
| RabbitMQ | `common-rabbitmq` | 5672 | `amqp://user:pass@common-rabbitmq:5672` |
| Elasticsearch | `common-elasticsearch` | 9200 | `http://common-elasticsearch:9200` |
| MinIO | `common-minio` | 9000 | `http://common-minio:9000` |

### Important Notes

- ✅ Use **network alias** as hostname (e.g., `common-mysql`)
- ✅ Use **container port** (e.g., `3306` for MySQL)
- ❌ Don't use `localhost` or `127.0.0.1`
- ❌ Don't use **published port** (that's for host machine access)

### Accessing Services from Host Machine

To access services from your host machine (e.g., using a database client):

```bash
# MySQL from host
mysql -h 127.0.0.1 -P 3306 -u root -p

# Redis from host
redis-cli -h localhost -p 6379

# PostgreSQL from host
psql -h localhost -p 5432 -U postgres
```


## 📝 Service-Specific Notes

### NFS Server

After starting the NFS server container:

1. Get the container IP:
   ```bash
   docker inspect common-nfs-server | grep IPAddress
   # or
   docker exec common-nfs-server hostname -I
   ```

2. Mount on your host machine:
   ```bash
   sudo mount -v -o vers=4,loud <container-ip>:/ /path/to/mount
   ```

3. **Important:** Unmount before stopping the container:
   ```bash
   sudo umount /path/to/mount
   ```

### Services Requiring Build

The following services require building before use:
- Elasticsearch
- Kibana
- Flagr
- Oracle
- RediSearch

Build them with:
```bash
docker compose build <service-name>
```

For detailed service-specific documentation, check the `readme.md` files in each service directory.

## 🤔 FAQ

### Can I run this in production?

**Short answer:** Not recommended without significant modifications.

**Long answer:** Docker Commons is optimized for local development. For production use, you must:
- Change all default credentials
- Enable TLS/SSL encryption
- Implement proper access controls
- Configure firewalls and network isolation
- Enable security features (authentication, authorization)
- Review and harden all configurations
- Implement monitoring and logging
- Set up proper backup procedures

See [SECURITY.md](SECURITY.md) for detailed security considerations.

### How do I change service ports?

Edit the `.env` file and change the `*_PUBLISH_PORT` variables:
```bash
# Change MySQL port from 3306 to 3307
MYSQL_PUBLISH_PORT=3307
```

Then restart the service:
```bash
docker compose up -d mysql
```

### Can I use different service versions?

Yes! Edit the `.env` file and change the `*_IMAGE_TAG` variables:
```bash
# Change MySQL version
MYSQL_IMAGE_TAG=8.0.35
```

Then pull and restart:
```bash
docker compose pull mysql
docker compose up -d mysql
```

### How do I backup my data?

Use the volume backup utility:
1. Edit `.env` and set `NAMED_VOLUME_TO_BACKUP=common-mysql-db`
2. Run: `docker compose up volume-backup`
3. Find backup in `.volume-backups/` directory

See `volumes-bnr/readme.md` for details.

### Services won't start or can't connect?

Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for solutions to common issues.

### How do I contribute?

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Reporting bugs
- Suggesting enhancements
- Adding new services
- Submitting pull requests

## 🗺️ Future Plans

- Support for Podman
- Additional service configurations
- More comprehensive service-specific documentation
- Enhanced health checks
- Better backup/restore utilities

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [LaraDock](https://github.com/laradock/laradock)
- Thanks to all contributors and users
- Built with ❤️ for the development community

## 📞 Support

- 📖 [Quick Start Guide](QUICKSTART.md)
- 🔧 [Troubleshooting Guide](TROUBLESHOOTING.md)
- 🐛 [Report Issues](https://github.com/a-h-abid/docker-commons/issues)
- 💬 [Discussions](https://github.com/a-h-abid/docker-commons/discussions)
