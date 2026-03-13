# Quick Start Guide

Get Docker Commons up and running in minutes with our simplified setup process.

## Prerequisites

- Docker Engine v20.10+ or Docker Desktop v4.0+
- Docker Compose v2.7+ (or v1.29+)

## Installation Methods

### Method 1: Interactive Setup (Recommended)

This is the easiest way to get started. The interactive setup wizard will guide you through the entire process.

```bash
# Clone the repository
git clone https://github.com/a-h-abid/docker-commons.git
cd docker-commons

# Run the interactive setup
./setup.sh
```

The setup wizard will:
1. ✓ Check that Docker and Docker Compose are installed
2. ✓ Create configuration files from examples
3. ✓ Let you choose which services to enable (with presets)
4. ✓ Automatically detect and add service dependencies
5. ✓ Create required Docker networks
6. ✓ Optionally pull and build Docker images

**Service Presets:**
- **Essential** (MySQL, Redis, Adminer) - Perfect for most projects
- **Full Stack** (MySQL, Redis, RabbitMQ, Elasticsearch, Adminer) - Complete development environment
- **Minimal** (Network only) - Just setup, no services
- **Custom** - Choose exactly what you need
- **All Services** - Enable everything

### Method 2: Manual Setup

If you prefer more control, follow these steps:

```bash
# 1. Clone the repository
git clone https://github.com/a-h-abid/docker-commons.git
cd docker-commons

# 2. Create configuration files
./copy-examples.sh           # Linux/macOS
# or
copy-examples.bat            # Windows

# 3. Edit .env file to select your services
# Edit the COMPOSE_FILE variable to include only the services you need

# 4. Create Docker networks
docker network create common-net
docker network create common-traefik-net  # Optional, only if using Traefik

# 5. Pull Docker images (optional but recommended)
docker compose pull

# 6. Build custom images (if needed)
docker compose build
```

## Starting Services

### Using the Commons CLI (Easy)

```bash
# Start all configured services
./commons.sh start

# Start specific services only
./commons.sh start mysql redis

# Check service status
./commons.sh status

# View logs
./commons.sh logs mysql

# Stop all services
./commons.sh stop
```

### Using Docker Compose Directly

```bash
# Start all services
docker compose up -d

# Start specific services
docker compose up -d mysql redis adminer

# Check status
docker compose ps

# View logs
docker compose logs --tail=100 mysql

# Stop all services
docker compose down
```

## Common Commands

The `commons.sh` script provides a simplified interface for managing your services:

```bash
./commons.sh help              # Show all available commands
./commons.sh list              # List all available services
./commons.sh start [services]  # Start services
./commons.sh stop [services]   # Stop services
./commons.sh restart [service] # Restart a service
./commons.sh logs <service>    # View logs
./commons.sh follow <service>  # Follow logs in real-time
./commons.sh health            # Check service health
./commons.sh pull              # Pull latest images
./commons.sh update            # Update and restart services
./commons.sh info              # Show environment info
```

## Connecting Your Application

To connect your application to these services:

1. **Add the network to your application's `docker-compose.yml`:**

```yaml
networks:
  common-net:
    external: true

services:
  your-app:
    # ... your service config
    networks:
      - common-net
```

2. **Use the service's network alias as the hostname:**

| Service | Hostname | Port |
|---------|----------|------|
| MySQL | `common-mysql` | 3306 |
| PostgreSQL | `common-postgres` | 5432 |
| Redis | `common-redis` | 6379 |
| MongoDB | `common-mongo` | 27017 |
| RabbitMQ | `common-rabbitmq` | 5672 (AMQP), 15672 (Management UI) |
| Elasticsearch | `common-elasticsearch` | 9200 |

**Example database configuration:**
```
Host: common-mysql
Port: 3306
Username: root
Password: root
```

## Service Selection Examples

### Essential Development Setup
Perfect for most web applications:
```bash
# During setup.sh, choose preset 1 (Essential)
# This enables: MySQL, Redis, Adminer
```

### Full-Stack Application
For complex applications with messaging and search:
```bash
# During setup.sh, choose preset 2 (Full Stack)
# This enables: MySQL, Redis, RabbitMQ, Elasticsearch, Adminer
```

### Custom Configuration
Choose exactly what you need:
```bash
# During setup.sh, choose preset 4 (Custom)
# Then select from the list of available services
```

## Troubleshooting

### Services won't start
```bash
# Check configuration is valid
./commons.sh validate

# View detailed error logs
./commons.sh logs <service-name>

# Check if required networks exist
./commons.sh networks
```

### Port conflicts
If you see "port already allocated" errors:
1. Edit `.env` file
2. Change the `*_PUBLISH_PORT` variables to unused ports
3. Restart the services

### Network doesn't exist
```bash
# Create networks manually
./commons.sh network-create
```

### Can't connect from application
1. Ensure your application is on the `common-net` network
2. Use the correct service alias (e.g., `common-mysql`)
3. Use the container port, not the published port (e.g., 3306 for MySQL, not the published port)

## Next Steps

- Review and customize service configurations in `.envs/` directory
- Check service-specific documentation in each service's folder
- Read [readme.md](readme.md) for detailed information
- See [CONTRIBUTING.md](CONTRIBUTING.md) if you want to contribute

## Service-Specific Notes

### Elasticsearch
- Requires building custom image on first setup
- Password is auto-generated on first start
- See [elasticsearch/readme.md](elasticsearch/readme.md) for details

### NFS Server
- After starting, requires mounting on host system
- See [nfs-server/readme.md](nfs-server/readme.md) for instructions

### Cassandra DSE
- Runs as a 3-node cluster
- Requires building custom image
- See [cassandra-dse/readme.md](cassandra-dse/readme.md)

### Apache Druid
- Requires Apache Zookeeper to be running
- Multiple services must be started together
- Auto-configured when selected via setup wizard

## Getting Help

- Run `./commons.sh help` for CLI command reference
- Check the main [readme.md](readme.md) for detailed documentation
- Visit service-specific readme files in each service directory
- Report issues at: https://github.com/a-h-abid/docker-commons/issues
