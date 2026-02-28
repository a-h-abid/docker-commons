#!/usr/bin/env bash

# Docker Commons Validation Script
# This script validates your Docker Compose configuration before running services

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "================================================"
echo "  Docker Commons Configuration Validator"
echo "================================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is installed${NC}"

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo -e "${RED}✗ Docker Compose is not available${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose is available${NC}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}✗ .env file not found${NC}"
    echo "  Run ./copy-examples.sh to create it"
    exit 1
fi
echo -e "${GREEN}✓ .env file exists${NC}"

# Check if docker-compose.override.yml exists
if [ ! -f docker-compose.override.yml ]; then
    echo -e "${RED}✗ docker-compose.override.yml not found${NC}"
    echo "  Run ./copy-examples.sh to create it"
    exit 1
fi
echo -e "${GREEN}✓ docker-compose.override.yml exists${NC}"

# Check if networks exist
echo ""
echo "Checking Docker networks..."
if ! docker network inspect common-net &> /dev/null; then
    echo -e "${YELLOW}⚠ Network 'common-net' does not exist${NC}"
    echo "  Create it with: docker network create common-net"
else
    echo -e "${GREEN}✓ Network 'common-net' exists${NC}"
fi

if ! docker network inspect common-traefik-net &> /dev/null; then
    echo -e "${YELLOW}⚠ Network 'common-traefik-net' does not exist (optional)${NC}"
    echo "  Create it with: docker network create common-traefik-net"
else
    echo -e "${GREEN}✓ Network 'common-traefik-net' exists${NC}"
fi

# Validate Docker Compose configuration
echo ""
echo "Validating Docker Compose configuration..."
if docker compose config > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker Compose configuration is valid${NC}"
else
    echo -e "${RED}✗ Docker Compose configuration has errors${NC}"
    echo "  Run 'docker compose config' to see details"
    exit 1
fi

# Check for common configuration issues
echo ""
echo "Checking for common issues..."

# Check if COMPOSE_FILE is set correctly in .env
if grep -q "COMPOSE_FILE=" .env; then
    echo -e "${GREEN}✓ COMPOSE_FILE is set in .env${NC}"
else
    echo -e "${YELLOW}⚠ COMPOSE_FILE not set in .env${NC}"
fi

# Check if COMPOSE_PATH_SEPARATOR is set correctly
if grep -q "COMPOSE_PATH_SEPARATOR=" .env; then
    echo -e "${GREEN}✓ COMPOSE_PATH_SEPARATOR is set in .env${NC}"
else
    echo -e "${YELLOW}⚠ COMPOSE_PATH_SEPARATOR not set in .env${NC}"
fi

# Check for unused services in override file
echo ""
echo "Configuration validated successfully!"
echo ""
echo "You can now run:"
echo "  docker compose pull           # Pull all images"
echo "  docker compose up -d          # Start all services"
echo "  docker compose up -d <service> # Start specific service"
echo ""
