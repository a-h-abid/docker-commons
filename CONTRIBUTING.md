# Contributing to Docker Commons

Thank you for your interest in contributing to Docker Commons! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Submitting Changes](#submitting-changes)
- [Coding Standards](#coding-standards)
- [Adding a New Service](#adding-a-new-service)

## Code of Conduct

This project adheres to a simple code of conduct: be respectful, be collaborative, and help create a welcoming environment for everyone.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- Clear and descriptive title
- Detailed steps to reproduce the problem
- Expected vs actual behavior
- Your environment (OS, Docker version, Docker Compose version)
- Relevant logs and configuration files (with sensitive data removed)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- Clear and descriptive title
- Detailed description of the proposed functionality
- Rationale explaining why this enhancement would be useful
- Example use cases

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the [Coding Standards](#coding-standards)
4. Test your changes thoroughly
5. Commit your changes with a descriptive commit message
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Setup

1. **Prerequisites:**
   - Docker Engine v20.10+ / Docker Desktop v4.0+
   - Docker Compose v2.7+ (or v1.29+)
   - Git

2. **Clone and Setup:**
   ```bash
   git clone https://github.com/a-h-abid/docker-commons.git
   cd docker-commons

   # Run the setup script
   ./copy-examples.sh  # Linux/macOS
   # or
   copy-examples.bat   # Windows
   ```

3. **Configure Environment:**
   - Edit `.env` file with your preferences
   - Edit `docker-compose.override.yml` to include only services you need
   - Update service-specific `.envs/{name}.env` files as needed

4. **Create Networks:**
   ```bash
   docker network create common-net
   docker network create common-traefik-net  # Optional, for Traefik
   ```

5. **Test Your Setup:**
   ```bash
   docker compose config  # Validate configuration
   docker compose pull    # Pull images
   docker compose up -d   # Start services
   ```

## Submitting Changes

### Commit Message Guidelines

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests after the first line

Example:
```
Add Redis Cluster configuration

- Add docker-compose override for Redis Cluster
- Add environment configuration example
- Update documentation with setup instructions

Fixes #123
```

### Pull Request Process

1. Update the README.md or relevant documentation with details of changes
2. Update the `.env.example` if you add new environment variables
3. Follow the existing code structure and naming conventions
4. Ensure all example files are properly named with `.example` suffix
5. Test your changes with a fresh setup
6. Update the services table in README.md if adding a new service

## Coding Standards

### File Naming Conventions

- Example files: `{name}.example.{ext}` (e.g., `.env.example`, `tree.ldif.example`)
- Docker Compose overrides: `docker-compose.override.{service}.yml`
- Environment files: `.envs/{service}.example.env`
- Documentation: `readme.md` (lowercase) for service-specific docs

### Docker Compose Standards

- Use external networks (`common-net`, `common-traefik-net`)
- Use consistent network aliases: `common-{service}`
- Define environment variables in `.env` file
- Use `${VARIABLE}` syntax for environment variable references
- Include restart policies where appropriate
- Use named volumes with `common-` prefix

### Shell Script Standards

- Use `#!/bin/bash` or `#!/usr/bin/env bash` shebang
- Add descriptive comments for complex logic
- Use `set -e` to exit on errors when appropriate
- Make scripts executable (`chmod +x script.sh`)
- Provide both Linux/macOS (.sh) and Windows (.bat) versions when possible

### Documentation Standards

- Keep README.md table format for service listings
- Document all environment variables with comments
- Provide examples for common configurations
- Include references to official documentation
- Use proper markdown formatting

## Adding a New Service

When adding a new service to Docker Commons, follow these steps:

1. **Create Service Directory** (if needed):
   ```bash
   mkdir {service-name}
   cd {service-name}
   ```

2. **Add Docker Compose Override File:**
   - Create `docker-compose.override.{service}.yml` in root directory
   - Follow existing patterns for service definition
   - Use `common-{service}` as network alias
   - Define environment variables in separate `.envs/` file

3. **Add Environment Configuration:**
   - Create `.envs/{service}.example.env`
   - Document all variables with comments
   - Use sensible defaults

4. **Update Main Environment File:**
   - Add image tag variable to `.env.example`
   - Add publish port variable to `.env.example`
   - Add any service-specific variables

5. **Update Copy Scripts:**
   - Add entry to `copy-examples.bat` for Windows users
   - The `copy-examples.sh` script should automatically detect the new `.example.env` file

6. **Add Documentation:**
   - Create `{service-name}/readme.md` with:
     - Brief service description
     - Key features relevant to the setup
     - Links to official documentation
     - Any special configuration notes

7. **Update README.md:**
   - Add service to the services table
   - Note if image build is required
   - Include network alias
   - Add any special notes in the "Service Specific Details" section if needed

8. **Test Your Addition:**
   ```bash
   # Validate configuration
   docker compose config

   # Test with fresh setup
   docker compose up -d {service}
   docker compose ps
   docker compose logs {service}
   ```

9. **Create .gitignore if Needed:**
   - Add `.gitignore` in service directory for data/log directories
   - Follow existing patterns

### Example Service Structure

```
{service-name}/
├── .gitignore
├── readme.md
├── compose.{service}.example.yaml  (if needed)
└── config-files.example/           (if needed)
```

Root level additions:
```
.envs/{service}.example.env
docker-compose.override.{service}.yml
```

## Questions?

If you have questions about contributing, feel free to:
- Open an issue with the `question` label
- Review existing issues and discussions
- Check the main README.md for general guidance

Thank you for contributing to Docker Commons!
