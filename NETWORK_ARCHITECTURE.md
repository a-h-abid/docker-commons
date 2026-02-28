# Network Architecture

This document explains how Docker networking is configured in Docker Commons and how to connect your applications.

## Overview

Docker Commons uses Docker's networking features to allow services to communicate with each other and with your applications. The architecture is designed to be:

- **Simple:** Easy to understand and use
- **Isolated:** Services don't interfere with each other
- **Flexible:** Connect only the services you need
- **Scalable:** Support multiple projects simultaneously

## Network Topology

```
┌─────────────────────────────────────────────────────────────┐
│                         Host Machine                         │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              common-net (bridge)                     │   │
│  │                                                      │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │   │
│  │  │  MySQL   │  │  Redis   │  │ RabbitMQ │          │   │
│  │  │          │  │          │  │          │          │   │
│  │  │ :3306    │  │ :6379    │  │ :5672    │          │   │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘          │   │
│  │       │             │             │                 │   │
│  │       │             │             │                 │   │
│  │  ┌────┴─────────────┴─────────────┴─────┐          │   │
│  │  │      Your Application Container       │          │   │
│  │  └───────────────────────────────────────┘          │   │
│  │                                                      │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         common-traefik-net (bridge) - Optional       │   │
│  │                                                      │   │
│  │  ┌──────────┐  ┌──────────────────────┐            │   │
│  │  │ Traefik  │──│ Your Web Application │            │   │
│  │  │  Proxy   │  │                      │            │   │
│  │  └────┬─────┘  └──────────────────────┘            │   │
│  │       │                                             │   │
│  └───────┼──────────────────────────────────────────────┘   │
│          │                                                  │
│     :80  │  :443                                            │
└──────────┼──────────────────────────────────────────────────┘
           │
      [Internet]
```

## Networks

### common-net

**Purpose:** Internal service communication

**Type:** Bridge network

**External:** Yes (created manually)

**Usage:**
- All Docker Commons services connect to this network
- Your application containers connect to this network
- Services communicate using network aliases

**Creation:**
```bash
docker network create common-net
```

**Inspection:**
```bash
docker network inspect common-net
```

### common-traefik-net

**Purpose:** Reverse proxy and web routing (optional)

**Type:** Bridge network

**External:** Yes (created manually)

**Usage:**
- Used when Traefik is enabled
- Routes HTTP/HTTPS traffic to web applications
- Provides domain-based routing

**Creation:**
```bash
docker network create common-traefik-net
```

## Service Network Aliases

Each service has a consistent network alias for easy connection:

| Service | Network Alias | Network |
|---------|---------------|---------|
| MySQL | `common-mysql` | common-net |
| PostgreSQL | `common-postgres` | common-net |
| Redis | `common-redis` | common-net |
| MongoDB | `common-mongo` | common-net |
| RabbitMQ | `common-rabbitmq` | common-net |
| Elasticsearch | `common-elasticsearch` | common-net |
| MinIO | `common-minio` | common-net |
| Cassandra | `common-cassandra` | common-net |
| LDAP | `common-ldap` | common-net |
| SFTP | `common-sftp` | common-net |
| Traefik | `traefik` | common-traefik-net |

## How It Works

### Internal Communication (Container to Container)

1. **DNS Resolution:** Docker's built-in DNS resolves network aliases to container IPs
2. **Direct Connection:** Containers communicate directly on the internal network
3. **No Port Publishing:** Services use container ports, not published ports
4. **Automatic Discovery:** Services find each other automatically via aliases

**Example:**
```yaml
# Your application container
services:
  myapp:
    networks:
      - common-net
    environment:
      # Use network alias and container port
      DB_HOST: common-mysql
      DB_PORT: 3306
```

### External Access (Host to Container)

1. **Port Publishing:** Services publish ports to the host machine
2. **localhost Access:** Access services from host using `localhost` or `127.0.0.1`
3. **Published Ports:** Use the ports defined in `.env` file

**Example:**
```bash
# From host machine
mysql -h 127.0.0.1 -P 3306 -u root -p

# From application container
mysql -h common-mysql -P 3306 -u root -p
```

## Connection Patterns

### Pattern 1: Simple Application

```yaml
# docker-compose.yml for your app
networks:
  common-net:
    external: true

services:
  webapp:
    image: myapp:latest
    networks:
      - common-net
    environment:
      DATABASE_URL: "mysql://user:pass@common-mysql:3306/dbname"
      REDIS_URL: "redis://common-redis:6379"
```

### Pattern 2: Multi-Service Application

```yaml
# docker-compose.yml for your app
networks:
  common-net:
    external: true
  app-internal:  # Private network for your app
    driver: bridge

services:
  web:
    networks:
      - app-internal
      - common-net
    environment:
      API_URL: "http://api:8080"
      DB_HOST: "common-mysql"

  api:
    networks:
      - app-internal
      - common-net
    environment:
      DB_HOST: "common-mysql"
      REDIS_HOST: "common-redis"
```

### Pattern 3: Traefik Integration

```yaml
# docker-compose.yml for your app
networks:
  common-net:
    external: true
  common-traefik-net:
    external: true

services:
  webapp:
    networks:
      - common-net
      - common-traefik-net
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myapp.rule=Host(`myapp.localhost`)"
      - "traefik.http.services.myapp.loadbalancer.server.port=80"
    environment:
      DB_HOST: "common-mysql"
```

## Network Isolation

### What's Isolated

- Services in different networks cannot communicate
- Each project can have its own internal network
- Docker Commons services don't interfere with other Docker projects

### What's Not Isolated

- All services on `common-net` can communicate with each other
- Published ports are accessible from the host
- Containers with host networking bypass isolation

## Best Practices

### DO ✅

1. **Use network aliases for service connections**
   ```yaml
   DB_HOST: common-mysql  # ✅ Good
   ```

2. **Use container ports in connection strings**
   ```yaml
   DB_PORT: 3306  # ✅ Container port
   ```

3. **Keep services on common-net for internal communication**
   ```yaml
   networks:
     - common-net  # ✅ Allows connection to services
   ```

4. **Use multiple networks for complex applications**
   ```yaml
   networks:
     - common-net      # For Docker Commons services
     - app-internal    # For internal app communication
   ```

5. **Document custom networks in your project**

### DON'T ❌

1. **Don't use localhost in connection strings (from containers)**
   ```yaml
   DB_HOST: localhost  # ❌ Won't work
   ```

2. **Don't use published ports in container connections**
   ```yaml
   DB_PORT: ${MYSQL_PUBLISH_PORT}  # ❌ Use 3306 instead
   ```

3. **Don't connect to services without being on common-net**
   ```yaml
   # ❌ Won't work without common-net
   services:
     app:
       networks:
         - default  # Only on default network
   ```

4. **Don't hardcode IP addresses**
   ```yaml
   DB_HOST: 172.18.0.5  # ❌ IPs can change
   ```

## Troubleshooting

### Service Can't Connect to Another Service

**Check:**
1. Both containers are on `common-net`
   ```bash
   docker network inspect common-net
   ```

2. Using the correct network alias
   ```bash
   docker exec myapp ping common-mysql
   ```

3. Service is actually running
   ```bash
   docker compose ps
   ```

### Name Resolution Fails

**Symptoms:**
- "Could not resolve host"
- "Name or service not known"

**Solutions:**
1. Restart both containers
   ```bash
   docker compose restart myapp mysql
   ```

2. Verify network configuration
   ```bash
   docker exec myapp cat /etc/resolv.conf
   ```

3. Check DNS from container
   ```bash
   docker exec myapp nslookup common-mysql
   ```

### Port Already in Use

**Symptoms:**
- "port is already allocated"
- "bind: address already in use"

**Solutions:**
1. Change the published port in `.env`
   ```bash
   MYSQL_PUBLISH_PORT=3307  # Changed from 3306
   ```

2. Stop conflicting service
   ```bash
   # Find what's using the port
   sudo lsof -i :3306
   ```

## Advanced Topics

### Custom Networks

Create additional networks for specific purposes:

```bash
# Create a network for monitoring services
docker network create monitoring-net

# In docker-compose.override.yml
networks:
  monitoring-net:
    external: true

services:
  grafana:
    networks:
      - common-net
      - monitoring-net
```

### Network Aliases

Services can have multiple aliases:

```yaml
services:
  mysql:
    networks:
      common-net:
        aliases:
          - common-mysql
          - database
          - db
```

### IPv6 Support

Enable IPv6 in Docker daemon (`/etc/docker/daemon.json`):

```json
{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}
```

### Network Drivers

Docker Commons uses bridge driver (default), but you can use others:

- **bridge:** Default, suitable for most cases
- **host:** Container shares host network (no isolation)
- **overlay:** For Docker Swarm (multi-host)
- **macvlan:** Container gets its own MAC address

## Security Considerations

1. **Network Isolation:** Use separate networks for different security zones
2. **Firewall Rules:** Configure host firewall to restrict published ports
3. **Encrypted Communication:** Use TLS/SSL for sensitive data
4. **Access Control:** Limit which containers can connect to which networks
5. **Monitoring:** Log and monitor network traffic

## Performance

### Tips for Better Performance

1. **Minimize Network Hops:** Keep communicating services on same network
2. **Use Local Volumes:** Better than network volumes for I/O intensive apps
3. **Enable Connection Pooling:** In your application
4. **Monitor Network Stats:**
   ```bash
   docker stats
   ```

### Bandwidth Limits

Limit container bandwidth if needed:

```yaml
services:
  myapp:
    networks:
      common-net:
        bandwidth:
          ingress: "100M"
          egress: "100M"
```

## References

- [Docker Networking Overview](https://docs.docker.com/network/)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [Bridge Network Driver](https://docs.docker.com/network/bridge/)
