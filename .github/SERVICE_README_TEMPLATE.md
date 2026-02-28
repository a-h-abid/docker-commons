# Service Documentation Template

Use this template when adding README documentation for a new service.

---

# {Service Name}

{Brief one-line description of what this service does}

## Overview

{A paragraph describing the service, its purpose, and why someone would use it}

## Features

- {Feature 1}
- {Feature 2}
- {Feature 3}

## Quick Start

### Starting the Service

```bash
docker compose up -d {service-name}
```

### Verifying the Service

```bash
# Check status
docker compose ps {service-name}

# View logs
docker compose logs -f {service-name}
```

## Configuration

### Environment Variables

The service can be configured using environment variables in `.envs/{service-name}.env`:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `VARIABLE_1` | Description of variable | `default_value` |
| `VARIABLE_2` | Description of variable | `default_value` |

### Volumes

| Container Path | Description | Persistence |
|----------------|-------------|-------------|
| `/path/in/container` | Description of what's stored here | Named volume |

### Ports

| Container Port | Published Port | Description |
|----------------|----------------|-------------|
| `xxxx` | `${SERVICE_PUBLISH_PORT}` | Description of what this port is for |

## Usage Examples

### Connecting from Your Application

**Docker Compose configuration:**
```yaml
services:
  myapp:
    networks:
      - common-net
    environment:
      SERVICE_HOST: common-{service-name}
      SERVICE_PORT: {port}
```

### Connecting from Host Machine

```bash
# Example command to connect from host
{example-command} -h localhost -p {port}
```

### Common Operations

#### Operation 1

```bash
# Command for operation 1
docker exec -it common-{service-name} {command}
```

#### Operation 2

```bash
# Command for operation 2
docker exec -it common-{service-name} {command}
```

## Web Interface (if applicable)

Access the web interface at: `http://localhost:{port}`

**Default Credentials:**
- Username: `{default-username}`
- Password: `{default-password}`

**⚠️ Important:** Change default credentials for production use!

## Troubleshooting

### Issue 1: {Common Issue}

**Symptoms:**
- {Symptom 1}
- {Symptom 2}

**Solution:**
```bash
# Steps to resolve
{command-1}
{command-2}
```

### Issue 2: {Another Common Issue}

**Symptoms:**
- {Symptom 1}

**Solution:**
{Description of solution}

## Advanced Configuration

### Custom Configuration File

You can provide a custom configuration file:

1. Create your config file in `{service-name}/custom-config.conf`
2. Uncomment the volume mount in `docker-compose.override.yml`:
   ```yaml
   {service-name}:
     volumes:
       - ./{service-name}/custom-config.conf:/path/in/container/config.conf
   ```
3. Restart the service

### Performance Tuning

{Tips for optimizing performance}

### Security Hardening

For production deployments:
- {Security tip 1}
- {Security tip 2}
- {Security tip 3}

## Backup and Restore

### Backup

```bash
# Backup data
docker compose up volume-backup
# Set NAMED_VOLUME_TO_BACKUP=common-{service-name}-data in .env
```

### Restore

```bash
# Restore data
docker compose up volume-restore
# Set NAMED_VOLUME_TO_RESTORE=common-{service-name}-data in .env
```

## Version Information

- **Current Version:** {version} (defined in `.env` as `{SERVICE}_IMAGE_TAG`)
- **Image:** `{docker-image}:{tag}`

To upgrade:
1. Update `{SERVICE}_IMAGE_TAG` in `.env`
2. Pull new image: `docker compose pull {service-name}`
3. Recreate container: `docker compose up -d {service-name}`

## Health Checks

The service includes a health check that monitors:
- {Health check 1}
- {Health check 2}

View health status:
```bash
docker inspect --format='{{json .State.Health}}' common-{service-name}
```

## Integration Examples

### Example 1: {Framework/Language}

```{language}
// Example code showing how to connect
{code-example}
```

### Example 2: {Another Framework/Language}

```{language}
# Example code
{code-example}
```

## Useful Commands

```bash
# Access service shell
docker exec -it common-{service-name} /bin/bash

# View resource usage
docker stats common-{service-name}

# Export data (if applicable)
docker exec common-{service-name} {export-command}

# Import data (if applicable)
docker exec -i common-{service-name} {import-command} < data.sql
```

## Additional Resources

- [Official Documentation](https://example.com/docs)
- [GitHub Repository](https://github.com/example/repo)
- [Docker Hub Image](https://hub.docker.com/r/example/image)
- [Community Forum](https://example.com/forum)

## Related Services

This service works well with:
- {Related Service 1} - {Why they work together}
- {Related Service 2} - {Why they work together}

## Known Limitations

- {Limitation 1}
- {Limitation 2}

## Support

For issues specific to this service configuration:
1. Check the [main troubleshooting guide](../TROUBLESHOOTING.md)
2. Review [GitHub Issues](https://github.com/a-h-abid/docker-commons/issues)
3. Consult official service documentation

---

**Last Updated:** {date}
**Maintainer:** {name}
