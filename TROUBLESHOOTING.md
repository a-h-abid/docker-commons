# Troubleshooting Guide

This guide helps you resolve common issues when using Docker Commons.

## Table of Contents

- [Setup Issues](#setup-issues)
- [Network Issues](#network-issues)
- [Service-Specific Issues](#service-specific-issues)
- [Performance Issues](#performance-issues)
- [Data and Volume Issues](#data-and-volume-issues)
- [Platform-Specific Issues](#platform-specific-issues)
- [Debugging Tips](#debugging-tips)

## Setup Issues

### Error: "network common-net not found"

**Solution:**
```bash
docker network create common-net
```

If using Traefik:
```bash
docker network create common-traefik-net
```

### Error: ".env file not found" or "docker-compose.override.yml not found"

**Solution:**
Run the setup script:
```bash
./copy-examples.sh  # Linux/macOS
copy-examples.bat   # Windows
```

### Error: "invalid compose project"

**Cause:** Your `COMPOSE_FILE` variable in `.env` might have incorrect separator or invalid file references.

**Solution:**
1. Open `.env` file
2. Check `COMPOSE_PATH_SEPARATOR`:
   - Use `:` for Linux/macOS
   - Use `;` for Windows
3. Verify all files in `COMPOSE_FILE` exist
4. Validate configuration: `docker compose config`

### Error: "permission denied" when running scripts

**Solution:**
```bash
chmod +x copy-examples.sh
chmod +x run.sh
chmod +x validate.sh
```

## Network Issues

### Services cannot communicate with each other

**Cause:** Services might not be on the same network.

**Solution:**
1. Verify all services are on `common-net`:
   ```bash
   docker network inspect common-net
   ```
2. Check your application's docker-compose.yml includes:
   ```yaml
   networks:
     common-net:
       external: true
   ```

### Cannot access service from application

**Checklist:**
1. Use the network alias as hostname (e.g., `common-mysql`, not `localhost`)
2. Use container port (e.g., `3306` for MySQL), not published port
3. Ensure both containers are on `common-net`
4. Verify service is running: `docker compose ps`

**Example correct configuration:**
```yaml
# Your application's docker-compose.yml
services:
  myapp:
    networks:
      - common-net
    environment:
      DB_HOST: common-mysql
      DB_PORT: 3306

networks:
  common-net:
    external: true
```

### Port already allocated error

**Cause:** Another service (or Docker Commons instance) is using the same port.

**Solution:**
1. Find the process using the port:
   ```bash
   # Linux/macOS
   sudo lsof -i :3306

   # Windows (PowerShell)
   netstat -ano | findstr :3306
   ```
2. Change the port in `.env` file:
   ```bash
   MYSQL_PUBLISH_PORT=3307
   ```
3. Restart the service:
   ```bash
   docker compose up -d mysql
   ```

## Service-Specific Issues

### MySQL: "Access denied for user"

**Solution:**
1. Check credentials in `.envs/mysql.env`
2. Recreate the container and volume:
   ```bash
   docker compose rm -sf mysql
   docker volume rm common-mysql-db
   docker compose up -d mysql
   ```

### MySQL: Character encoding issues

**Solution:**
The default configuration already includes UTF-8 settings. If you still have issues:
1. Check `docker-compose.override.yml` includes:
   ```yaml
   mysql:
     command:
       - --character-set-server=utf8mb4
       - --collation-server=utf8mb4_unicode_ci
   ```

### Redis: Connection refused

**Solution:**
1. Check if Redis is running: `docker compose ps redis`
2. Check logs: `docker compose logs redis`
3. Verify network connection from your app
4. Use hostname `common-redis` and port `6379`

### Elasticsearch: "max virtual memory areas vm.max_map_count [65530] is too low"

**Solution:**
```bash
# Linux
sudo sysctl -w vm.max_map_count=262144

# To make it permanent
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Docker Desktop (Windows/macOS)
# Add to ~/.docker/daemon.json or Docker Desktop settings
```

### RabbitMQ: Management interface not accessible

**Solution:**
1. Verify port mapping: `docker compose ps rabbitmq`
2. Access at `http://localhost:15672` (default)
3. Default credentials: guest/guest (change in `.envs/rabbitmq.env`)

### PostgreSQL: "FATAL: password authentication failed"

**Solution:**
1. Check credentials in `.envs/postgres.env`
2. If changing password, recreate the volume:
   ```bash
   docker compose rm -sf postgres
   docker volume rm common-postgres-data
   docker compose up -d postgres
   ```

### LDAP: Cannot connect or authenticate

**Solution:**
1. Check LDAP configuration in `.envs/ldap.env`
2. Verify LDAP admin credentials
3. Check if `tree.ldif` was loaded:
   ```bash
   docker compose logs ldap | grep -i "ldif"
   ```

## Performance Issues

### Services are slow to start

**Causes:**
- Limited Docker resources
- Too many services running simultaneously
- Image downloads in progress

**Solutions:**
1. Increase Docker resources in Docker Desktop settings:
   - CPUs: 4+
   - Memory: 8GB+
   - Disk: Sufficient space

2. Start only needed services:
   ```bash
   docker compose up -d mysql redis
   ```

3. Check Docker disk usage:
   ```bash
   docker system df
   ```

### High CPU/Memory usage

**Solutions:**
1. Check which containers are using resources:
   ```bash
   docker stats
   ```

2. Limit service resources in `docker-compose.override.yml`:
   ```yaml
   services:
     mysql:
       deploy:
         resources:
           limits:
             cpus: '2'
             memory: 2G
   ```

3. Stop unused services:
   ```bash
   docker compose rm -sf <service-name>
   ```

### Slow database queries

**For MySQL:**
1. Check slow query log
2. Adjust MySQL configuration in `mysql/my_custom.cnf`
3. Increase memory allocation

**For PostgreSQL:**
1. Check pg_stat_statements
2. Adjust PostgreSQL settings in `.envs/postgres.env`

## Data and Volume Issues

### Lost data after container restart

**Cause:** Data not persisted to volumes.

**Solution:**
1. Verify volume configuration in `docker-compose.override.yml`
2. Check existing volumes:
   ```bash
   docker volume ls | grep common
   ```
3. Ensure volume mappings are correct

### Cannot delete volume - "volume is in use"

**Solution:**
```bash
# Stop all containers using the volume
docker compose down

# Remove specific service
docker compose rm -sf <service-name>

# Force remove volume
docker volume rm <volume-name>
```

### Backup data before removing volumes

**Solution:**
Use the volume backup service:
1. Edit `.env` and set `NAMED_VOLUME_TO_BACKUP`
2. Run:
   ```bash
   docker compose up volume-backup
   ```
3. Check `.volume-backups/` directory

See `volumes-bnr/readme.md` for details.

## Platform-Specific Issues

### Windows: Path separators not working

**Solution:**
In `.env` file, use semicolon:
```bash
COMPOSE_PATH_SEPARATOR=;
```

### Windows: Drive mounting issues

**Solution:**
1. Enable drive sharing in Docker Desktop settings
2. Use Linux containers (not Windows containers)
3. Consider using WSL2

### macOS: Performance issues with volumes

**Cause:** macOS file sharing is slower than Linux.

**Solutions:**
1. Use Docker's cached or delegated consistency mode:
   ```yaml
   volumes:
     - ./data:/data:cached
   ```
2. Use named volumes instead of bind mounts when possible
3. Consider using Docker Desktop with VirtioFS

### Linux: Permission denied for volumes

**Solution:**
1. Check directory permissions
2. Add your user to docker group:
   ```bash
   sudo usermod -aG docker $USER
   ```
3. Log out and back in

### WSL2: Cannot connect to services

**Solution:**
1. Use WSL2 IP address or `localhost`
2. Ensure Docker Desktop is using WSL2 backend
3. Check Windows firewall settings

## Debugging Tips

### View service logs

```bash
# All services
docker compose logs

# Specific service
docker compose logs mysql

# Follow logs
docker compose logs -f redis

# Last 100 lines
docker compose logs --tail=100 rabbitmq
```

### Check service status

```bash
# List running services
docker compose ps

# Detailed inspection
docker compose ps <service-name>

# Check specific container
docker inspect <container-id>
```

### Validate configuration

```bash
# Validate and view merged configuration
docker compose config

# Check for syntax errors
docker compose config --quiet
```

### Test network connectivity

```bash
# From your application container
docker exec -it <your-app-container> ping common-mysql

# Test DNS resolution
docker exec -it <your-app-container> nslookup common-mysql

# Test port connectivity
docker exec -it <your-app-container> nc -zv common-mysql 3306
```

### Inspect networks

```bash
# List all networks
docker network ls

# Inspect specific network
docker network inspect common-net

# See which containers are on a network
docker network inspect common-net | grep -A 5 Containers
```

### Clean up resources

```bash
# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v

# Remove unused resources
docker system prune

# Remove unused volumes (CAUTION: removes data!)
docker volume prune
```

### Reset everything

If nothing works, start fresh:

```bash
# Stop and remove everything
docker compose down -v

# Remove networks
docker network rm common-net common-traefik-net

# Clean up
docker system prune -a

# Start from scratch
docker network create common-net
./copy-examples.sh
docker compose pull
docker compose up -d
```

## Getting Help

If you're still experiencing issues:

1. Check existing [GitHub Issues](https://github.com/a-h-abid/docker-commons/issues)
2. Review service-specific documentation in `{service}/readme.md`
3. Check official service documentation
4. Create a new GitHub issue with:
   - Description of the problem
   - Steps to reproduce
   - Error messages and logs
   - Your environment (OS, Docker version, etc.)
   - Relevant configuration (with sensitive data removed)

## Useful Commands Reference

```bash
# Configuration
docker compose config              # Validate and view configuration
./validate.sh                      # Run validation script

# Services
docker compose up -d              # Start all services
docker compose up -d mysql redis  # Start specific services
docker compose down               # Stop all services
docker compose restart mysql      # Restart specific service
docker compose rm -sf mysql       # Remove service container

# Monitoring
docker compose ps                 # List services
docker compose logs -f mysql      # Follow service logs
docker stats                      # Resource usage
docker compose top                # Running processes

# Images
docker compose pull               # Pull all images
docker compose pull mysql         # Pull specific image
docker compose build              # Build custom images

# Volumes
docker volume ls                  # List volumes
docker volume inspect <name>      # Inspect volume
docker volume rm <name>           # Remove volume

# Networks
docker network ls                 # List networks
docker network inspect common-net # Inspect network
```
