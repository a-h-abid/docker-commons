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

# Function to resolve the published port for a service
resolve_port() {
    local service_name="$1"
    local default_port="$2"
    local mapped

    # Try to get the published port from docker compose
    mapped=$(docker compose port "$service_name" "$default_port" 2>/dev/null | head -n 1 || true)
    if [ -n "$mapped" ]; then
        # docker compose port output format is usually "0.0.0.0:12345" or "[::]:12345"
        echo "${mapped##*:}"
        return 0
    fi

    # Fall back to default port
    echo "$default_port"
}

# Check common services
# Format: service_name check_type target port

# Databases
if echo "$running_services" | grep -q "mysql"; then
    mysql_port=$(resolve_port "mysql" "3306")
    check_service "mysql" "tcp" "" "$mysql_port" || true
fi

if echo "$running_services" | grep -q "postgres"; then
    postgres_port=$(resolve_port "postgres" "5432")
    check_service "postgres" "tcp" "" "$postgres_port" || true
fi

if echo "$running_services" | grep -q "mongo"; then
    mongo_port=$(resolve_port "mongo" "27017")
    check_service "mongo" "tcp" "" "$mongo_port" || true
fi

if echo "$running_services" | grep -q "cassandra"; then
    cassandra_port=$(resolve_port "cassandra" "9042")
    check_service "cassandra" "tcp" "" "$cassandra_port" || true
fi

# Cache & Message Queues
if echo "$running_services" | grep -q "redis"; then
    redis_port=$(resolve_port "redis" "6379")
    check_service "redis" "tcp" "" "$redis_port" || true
fi

if echo "$running_services" | grep -q "rabbitmq"; then
    # Use TCP check on AMQP port instead of HTTP management API
    rabbitmq_port=$(resolve_port "rabbitmq" "5672")
    check_service "rabbitmq" "tcp" "" "$rabbitmq_port" || true
fi

# Search & Analytics
if echo "$running_services" | grep -q "elasticsearch"; then
    elasticsearch_port=$(resolve_port "elasticsearch" "9200")
    check_service "elasticsearch" "http" "/_cluster/health" "$elasticsearch_port" || true
fi

if echo "$running_services" | grep -q "kibana"; then
    kibana_port=$(resolve_port "kibana" "5601")
    check_service "kibana" "http" "/api/status" "$kibana_port" || true
fi

# Development Tools
if echo "$running_services" | grep -q "adminer"; then
    adminer_port=$(resolve_port "adminer" "8000")
    check_service "adminer" "http" "/" "$adminer_port" || true
fi

if echo "$running_services" | grep -q "mailhog"; then
    mailhog_port=$(resolve_port "mailhog" "8025")
    check_service "mailhog" "http" "/" "$mailhog_port" || true
fi

if echo "$running_services" | grep -q "maildev"; then
    maildev_port=$(resolve_port "maildev" "1080")
    check_service "maildev" "http" "/" "$maildev_port" || true
fi

if echo "$running_services" | grep -q "portainer"; then
    portainer_port=$(resolve_port "portainer" "9443")
    check_service "portainer" "http" "/api/status" "$portainer_port" || true
fi

# Storage
if echo "$running_services" | grep -q "minio"; then
    minio_port=$(resolve_port "minio" "9000")
    check_service "minio" "http" "/minio/health/live" "$minio_port" || true
fi

# Observability
if echo "$running_services" | grep -q "grafana"; then
    grafana_port=$(resolve_port "grafana" "3000")
    check_service "grafana" "http" "/api/health" "$grafana_port" || true
fi

if echo "$running_services" | grep -q "jaeger"; then
    jaeger_port=$(resolve_port "jaeger" "16686")
    check_service "jaeger" "http" "/" "$jaeger_port" || true
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
