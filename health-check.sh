#!/usr/bin/env bash

# Health Check Script for Docker Commons Services
# This script checks the health status of running services

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "================================================"
echo "  Docker Commons Services Health Check"
echo "================================================"
echo ""

# Get list of running services
running_services=$(docker compose ps --services --filter "status=running" 2>/dev/null)

if [ -z "$running_services" ]; then
    echo -e "${YELLOW}No services are currently running.${NC}"
    exit 0
fi

echo "Checking health status of running services..."
echo ""

# Function to check if a service is responding
check_service() {
    local service=$1
    local check_type=$2
    local target=$3
    local port=$4

    case $check_type in
        "tcp")
            if nc -z localhost "$port" 2>/dev/null; then
                echo -e "${GREEN}✓${NC} $service - TCP connection successful on port $port"
                return 0
            else
                echo -e "${RED}✗${NC} $service - Cannot connect to port $port"
                return 1
            fi
            ;;
        "http")
            if curl -sf "http://localhost:$port$target" > /dev/null 2>&1; then
                echo -e "${GREEN}✓${NC} $service - HTTP endpoint responding at port $port"
                return 0
            else
                echo -e "${RED}✗${NC} $service - HTTP endpoint not responding at port $port"
                return 1
            fi
            ;;
        "docker")
            local health=$(docker inspect --format='{{.State.Health.Status}}' "common-$service" 2>/dev/null)
            if [ "$health" = "healthy" ]; then
                echo -e "${GREEN}✓${NC} $service - Container health check passed"
                return 0
            elif [ "$health" = "starting" ]; then
                echo -e "${YELLOW}⚠${NC} $service - Container is starting..."
                return 0
            elif [ -z "$health" ]; then
                echo -e "${BLUE}ℹ${NC} $service - No health check configured"
                return 0
            else
                echo -e "${RED}✗${NC} $service - Container health check failed (status: $health)"
                return 1
            fi
            ;;
        *)
            echo -e "${BLUE}ℹ${NC} $service - Running (no health check configured)"
            return 0
            ;;
    esac
}

# Check common services
# Format: service_name check_type target port

# Databases
if echo "$running_services" | grep -q "mysql"; then
    check_service "mysql" "tcp" "" "3306" || true
fi

if echo "$running_services" | grep -q "postgres"; then
    check_service "postgres" "tcp" "" "5432" || true
fi

if echo "$running_services" | grep -q "mongo"; then
    check_service "mongo" "tcp" "" "27017" || true
fi

if echo "$running_services" | grep -q "cassandra"; then
    check_service "cassandra" "tcp" "" "9042" || true
fi

# Cache & Message Queues
if echo "$running_services" | grep -q "redis"; then
    check_service "redis" "tcp" "" "6379" || true
fi

if echo "$running_services" | grep -q "rabbitmq"; then
    check_service "rabbitmq" "http" "/api/health/checks/alarms" "15672" || true
fi

# Search & Analytics
if echo "$running_services" | grep -q "elasticsearch"; then
    check_service "elasticsearch" "http" "/_cluster/health" "9200" || true
fi

if echo "$running_services" | grep -q "kibana"; then
    check_service "kibana" "http" "/api/status" "5601" || true
fi

# Development Tools
if echo "$running_services" | grep -q "adminer"; then
    check_service "adminer" "http" "/" "8000" || true
fi

if echo "$running_services" | grep -q "mailhog"; then
    check_service "mailhog" "http" "/" "8025" || true
fi

if echo "$running_services" | grep -q "maildev"; then
    check_service "maildev" "http" "/" "1080" || true
fi

if echo "$running_services" | grep -q "portainer"; then
    check_service "portainer" "http" "/api/status" "9443" || true
fi

# Storage
if echo "$running_services" | grep -q "minio"; then
    check_service "minio" "http" "/minio/health/live" "9000" || true
fi

# Observability
if echo "$running_services" | grep -q "grafana"; then
    check_service "grafana" "http" "/api/health" "3000" || true
fi

if echo "$running_services" | grep -q "jaeger"; then
    check_service "jaeger" "http" "/" "16686" || true
fi

echo ""
echo "================================================"
echo "Health check complete!"
echo ""
echo "For detailed logs, run:"
echo "  docker compose logs <service-name>"
echo ""
echo "To check container health status:"
echo "  docker compose ps"
echo "================================================"
