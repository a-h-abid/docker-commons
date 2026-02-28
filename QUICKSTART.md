# Quick Start Guide

Get up and running with Docker Commons in 5 minutes!

## Prerequisites

- Docker Engine v20.10+ or Docker Desktop v4.0+
- Docker Compose v2.7+ (use `docker compose`) or v1.29+ (use `docker-compose`)
- Git (for cloning the repository)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/a-h-abid/docker-commons.git
cd docker-commons
```

### 2. Run Setup Script

**Linux/macOS:**
```bash
chmod +x copy-examples.sh
./copy-examples.sh
```

**Windows:**
```cmd
copy-examples.bat
```

This creates:
- `.env` from `.env.example`
- `docker-compose.override.yml` from `docker-compose.override.example.yml`
- Individual `.envs/{service}.env` files from `.envs/{service}.example.env`

### 3. Create Docker Networks

```bash
docker network create common-net
docker network create common-traefik-net  # Optional, only if using Traefik
```

### 4. Configure Services

Edit `.env` file to select which services you want:

```bash
# Example: Start with MySQL, Redis, and Adminer
COMPOSE_FILE=docker-compose.yml:docker-compose.override.mysql.yml:docker-compose.override.redis.yml:docker-compose.override.adminer.yml:docker-compose.override.yml
```

**Important:** Keep `docker-compose.override.yml` at the end!

### 5. Pull Images

```bash
docker compose pull
```

### 6. Start Services

```bash
# Start all configured services
docker compose up -d

# Or start specific services only
docker compose up -d mysql redis adminer
```

### 7. Verify Services

```bash
docker compose ps
```

## Common Configurations

### Web Development Stack (MySQL + Redis + Adminer)

```bash
# In .env file, set:
COMPOSE_FILE=docker-compose.yml:docker-compose.override.mysql.yml:docker-compose.override.redis.yml:docker-compose.override.adminer.yml:docker-compose.override.yml

# Start services
docker compose up -d

# Access Adminer at http://localhost:8000
# MySQL: host=common-mysql, port=3306
# Redis: host=common-redis, port=6379
```

### Microservices Stack (PostgreSQL + RabbitMQ + Redis)

```bash
# In .env file, set:
COMPOSE_FILE=docker-compose.yml:docker-compose.override.postgres.yml:docker-compose.override.rabbitmq.yml:docker-compose.override.redis.yml:docker-compose.override.yml

# Start services
docker compose up -d
```

### Search Stack (Elasticsearch + Kibana)

```bash
# In .env file, set:
COMPOSE_FILE=docker-compose.yml:docker-compose.override.elasticsearch.yml:docker-compose.override.yml

# Build Kibana if needed
docker compose build kibana

# Start services
docker compose up -d

# Access Kibana at http://localhost:5601
```

### Email Testing (MailHog or MailDev)

```bash
# In .env file, set:
COMPOSE_FILE=docker-compose.yml:docker-compose.override.mailhog.yml:docker-compose.override.yml

# Start services
docker compose up -d mailhog

# Access MailHog at http://localhost:8025
# SMTP server: common-mailhog:1025
```

## Connecting Your Application

### Step 1: Update Your Application's docker-compose.yml

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
      # Use service network aliases as hostnames
      DB_HOST: common-mysql
      DB_PORT: 3306
      REDIS_HOST: common-redis
      REDIS_PORT: 6379
```

### Step 2: Configure Application

Use these connection details in your application:

| Service | Hostname | Port |
|---------|----------|------|
| MySQL | common-mysql | 3306 |
| PostgreSQL | common-postgres | 5432 |
| Redis | common-redis | 6379 |
| RabbitMQ | common-rabbitmq | 5672 (AMQP), 15672 (Management) |
| MongoDB | common-mongo | 27017 |
| Elasticsearch | common-elasticsearch | 9200 |
| MinIO | common-minio | 9000 |

### Step 3: Start Your Application

```bash
cd /path/to/your/application
docker compose up -d
```

Your application can now communicate with Docker Commons services!

## Service-Specific Quick Tips

### MySQL

**Access from host:**
```bash
mysql -h 127.0.0.1 -P 3306 -u root -p
```

**Default credentials:** Check `.envs/mysql.env`

### PostgreSQL

**Access from host:**
```bash
psql -h localhost -p 5432 -U postgres
```

**Default credentials:** Check `.envs/postgres.env`

### Redis

**Access from host:**
```bash
redis-cli -h localhost -p 6379
```

**With Redis Commander:** http://localhost:8081

### RabbitMQ

**Management UI:** http://localhost:15672

**Default credentials:** guest/guest

### Adminer

**Access:** http://localhost:8000

**Login to MySQL:**
- System: MySQL
- Server: common-mysql
- Username: root
- Password: (from `.envs/mysql.env`)
- Database: (your database name)

### MinIO (S3-compatible storage)

**Console:** http://localhost:9001

**API endpoint:** http://localhost:9000

**Default credentials:** Check `.envs/minio.env`

## Useful Commands

```bash
# Check service status
docker compose ps

# View logs
docker compose logs -f mysql

# Restart a service
docker compose restart redis

# Stop all services
docker compose down

# Stop and remove volumes (deletes data!)
docker compose down -v

# Pull latest images
docker compose pull

# Remove specific service
docker compose rm -sf mysql
```

## Validating Your Setup

Run the validation script:

```bash
chmod +x validate.sh
./validate.sh
```

## Changing Ports

If a port is already in use, edit `.env` file:

```bash
# Change MySQL port from 3306 to 3307
MYSQL_PUBLISH_PORT=3307
```

Then restart:
```bash
docker compose up -d mysql
```

## Troubleshooting

### "network common-net not found"
```bash
docker network create common-net
```

### "port is already allocated"
Change the port in `.env` file or stop the conflicting service.

### Services can't communicate
- Ensure both are on `common-net` network
- Use network alias as hostname (e.g., `common-mysql`)
- Use container port, not published port

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more help.

## Next Steps

- Read [README.md](readme.md) for complete documentation
- Check [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
- Review [SECURITY.md](SECURITY.md) for security considerations
- Explore service-specific README files in service directories

## Example: Complete Setup for Laravel Application

```bash
# 1. Clone docker-commons
git clone https://github.com/a-h-abid/docker-commons.git
cd docker-commons

# 2. Setup
./copy-examples.sh

# 3. Configure services in .env
# Keep MySQL, Redis, Mailhog, and Adminer
# Edit COMPOSE_FILE to include only these services

# 4. Create network
docker network create common-net

# 5. Start services
docker compose up -d

# 6. Update your Laravel .env
DB_HOST=common-mysql
DB_PORT=3306
REDIS_HOST=common-redis
REDIS_PORT=6379
MAIL_HOST=common-mailhog
MAIL_PORT=1025

# 7. Update your Laravel docker-compose.yml to use common-net

# 8. Start your Laravel app
cd /path/to/laravel
docker compose up -d

# Done! Your Laravel app now uses Docker Commons services
```

## Getting Help

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Review [GitHub Issues](https://github.com/a-h-abid/docker-commons/issues)
- Read service-specific documentation in service directories

Happy developing! 🚀
