#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Script version
VERSION="1.0.0"

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_header() {
    echo -e "\n${CYAN}=== $1 ===${NC}\n"
}

# Function to check if docker compose is available
get_compose_cmd() {
    if docker compose version &> /dev/null; then
        echo "docker compose"
    elif command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    else
        print_error "Docker Compose is not installed"
        exit 1
    fi
}

# Function to show help
show_help() {
    cat << EOF
${BLUE}Docker Commons Management CLI${NC} - Version ${VERSION}

${YELLOW}Usage:${NC}
  ./commons.sh [COMMAND] [OPTIONS]

${YELLOW}Commands:${NC}

  ${GREEN}Setup & Configuration:${NC}
    setup              Run interactive setup wizard
    config             Show current Docker Compose configuration
    validate           Validate Docker Compose files

  ${GREEN}Service Management:${NC}
    start [services]   Start all services or specific service(s)
    stop [services]    Stop all services or specific service(s)
    restart [services] Restart all services or specific service(s)
    status             Show status of all services
    ps                 List running services (alias for status)

  ${GREEN}Service Information:${NC}
    list               List all available services
    logs [service]     Show logs for a service (last 100 lines)
    follow [service]   Follow logs for a service in real-time
    health [service]   Check health status of service(s)

  ${GREEN}Maintenance:${NC}
    pull [services]    Pull latest images for service(s)
    build [services]   Build custom images for service(s)
    clean              Remove stopped containers
    prune              Remove unused Docker resources (images, volumes, networks)
    update             Update and restart services

  ${GREEN}Network Management:${NC}
    networks           List Docker Commons networks
    network-create     Create required Docker networks
    network-inspect    Inspect Docker Commons networks

  ${GREEN}Information:${NC}
    help               Show this help message
    version            Show version information
    info               Show Docker Commons environment info

${YELLOW}Examples:${NC}
  ./commons.sh start                    # Start all configured services
  ./commons.sh start mysql redis        # Start only MySQL and Redis
  ./commons.sh logs mysql               # View MySQL logs
  ./commons.sh follow redis             # Follow Redis logs in real-time
  ./commons.sh restart rabbitmq         # Restart RabbitMQ
  ./commons.sh health                   # Check health of all services
  ./commons.sh stop                     # Stop all services

${YELLOW}Quick Start:${NC}
  1. Run setup: ${GREEN}./setup.sh${NC}
  2. Start services: ${GREEN}./commons.sh start${NC}
  3. Check status: ${GREEN}./commons.sh status${NC}

EOF
}

# Function to show version
show_version() {
    echo "Docker Commons Management CLI - Version ${VERSION}"
}

# Function to start services
start_services() {
    local compose_cmd=$(get_compose_cmd)
    local services="$@"

    if [ -z "$services" ]; then
        print_header "Starting All Services"
        print_info "This will start all services defined in your COMPOSE_FILE"
    else
        print_header "Starting Services: $services"
    fi

    if $compose_cmd up -d $services; then
        echo ""
        print_success "Services started successfully"
        echo ""
        print_info "Run './commons.sh status' to check service status"
        print_info "Run './commons.sh logs <service>' to view logs"
    else
        echo ""
        print_error "Failed to start services"
        exit 1
    fi
}

# Function to stop services
stop_services() {
    local compose_cmd=$(get_compose_cmd)
    local services="$@"

    if [ -z "$services" ]; then
        print_header "Stopping All Services"
        if $compose_cmd down; then
            print_success "All services stopped"
        else
            print_error "Failed to stop services"
            exit 1
        fi
    else
        print_header "Stopping Services: $services"
        if $compose_cmd rm -sf $services; then
            print_success "Services stopped: $services"
        else
            print_error "Failed to stop services"
            exit 1
        fi
    fi
}

# Function to restart services
restart_services() {
    local services="$@"

    if [ -z "$services" ]; then
        print_header "Restarting All Services"
        stop_services
        start_services
    else
        print_header "Restarting Services: $services"
        stop_services $services
        start_services $services
    fi
}

# Function to show service status
show_status() {
    local compose_cmd=$(get_compose_cmd)
    print_header "Service Status"

    if ! $compose_cmd ps; then
        print_error "Failed to get service status"
        exit 1
    fi

    echo ""
    print_info "Tip: Use './commons.sh health' for detailed health checks"
}

# Function to list available services
list_services() {
    local compose_cmd=$(get_compose_cmd)
    print_header "Available Services"

    # Get all service names from compose config
    local services=$($compose_cmd config --services 2>/dev/null)

    if [ -z "$services" ]; then
        print_warning "No services configured"
        print_info "Run './setup.sh' to configure services"
        return
    fi

    local count=0
    echo -e "${CYAN}Service Name${NC}          ${CYAN}Status${NC}"
    echo "----------------------------------------"

    for service in $services; do
        count=$((count + 1))
        local is_running=$($compose_cmd ps -q $service 2>/dev/null)
        if [ -n "$is_running" ]; then
            echo -e "$(printf "%-20s" "$service") ${GREEN}Running${NC}"
        else
            echo -e "$(printf "%-20s" "$service") ${YELLOW}Stopped${NC}"
        fi
    done

    echo ""
    print_info "Total services configured: $count"
    echo ""
}

# Function to show logs
show_logs() {
    local compose_cmd=$(get_compose_cmd)
    local service="$1"
    local lines="${2:-100}"

    if [ -z "$service" ]; then
        print_error "Please specify a service name"
        print_info "Usage: ./commons.sh logs <service> [lines]"
        exit 1
    fi

    print_header "Logs for: $service (last $lines lines)"

    if ! $compose_cmd logs --tail=$lines $service; then
        print_error "Failed to get logs for service: $service"
        exit 1
    fi
}

# Function to follow logs
follow_logs() {
    local compose_cmd=$(get_compose_cmd)
    local service="$1"

    if [ -z "$service" ]; then
        print_error "Please specify a service name"
        print_info "Usage: ./commons.sh follow <service>"
        exit 1
    fi

    print_header "Following logs for: $service"
    print_info "Press Ctrl+C to stop"
    echo ""

    $compose_cmd logs -f $service
}

# Function to check health
check_health() {
    local compose_cmd=$(get_compose_cmd)
    local service="$1"

    print_header "Health Status"

    if [ -z "$service" ]; then
        # Check all services
        $compose_cmd ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    else
        # Check specific service
        $compose_cmd ps $service --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    fi

    echo ""
}

# Function to pull images
pull_images() {
    local compose_cmd=$(get_compose_cmd)
    local services="$@"

    if [ -z "$services" ]; then
        print_header "Pulling All Images"
        print_info "This may take several minutes..."
    else
        print_header "Pulling Images for: $services"
    fi

    if $compose_cmd pull $services; then
        echo ""
        print_success "Images pulled successfully"
    else
        echo ""
        print_warning "Some images could not be pulled (this is normal for custom-built services)"
    fi
}

# Function to build images
build_images() {
    local compose_cmd=$(get_compose_cmd)
    local services="$@"

    if [ -z "$services" ]; then
        print_header "Building All Custom Images"
        print_info "This may take several minutes..."
    else
        print_header "Building Images for: $services"
    fi

    if $compose_cmd build $services; then
        echo ""
        print_success "Images built successfully"
    else
        echo ""
        print_error "Failed to build images"
        exit 1
    fi
}

# Function to show config
show_config() {
    local compose_cmd=$(get_compose_cmd)
    print_header "Current Docker Compose Configuration"

    $compose_cmd config
}

# Function to validate compose files
validate_config() {
    print_header "Validating Configuration"

    if [ -x "./validate.sh" ]; then
        if ./validate.sh; then
            print_success "Configuration is valid"
        else
            print_error "Configuration validation failed"
            exit 1
        fi
    else
        local compose_cmd=$(get_compose_cmd)
        if $compose_cmd config --quiet; then
            print_success "Configuration is valid"
        else
            print_error "Configuration validation failed"
            exit 1
        fi
    fi
}

# Function to clean stopped containers
clean_containers() {
    local compose_cmd=$(get_compose_cmd)
    print_header "Cleaning Stopped Containers"

    $compose_cmd rm -f
    print_success "Stopped containers removed"
}

# Function to prune Docker resources
prune_resources() {
    print_header "Pruning Docker Resources"
    print_warning "This will remove:"
    echo "  - All stopped containers"
    echo "  - All networks not used by at least one container"
    echo "  - All dangling images"
    echo "  - All dangling build cache"
    echo ""

    read -p "Are you sure you want to continue? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        docker system prune -f
        print_success "Docker resources pruned"
    else
        print_info "Prune cancelled"
    fi
}

# Function to update services
update_services() {
    print_header "Updating Services"

    print_info "Pulling latest images..."
    pull_images

    echo ""
    print_info "Restarting services with new images..."
    restart_services

    echo ""
    print_success "Services updated successfully"
}

# Function to list networks
list_networks() {
    print_header "Docker Commons Networks"

    echo -e "${CYAN}Network Name${NC}              ${CYAN}Status${NC}"
    echo "----------------------------------------"

    if docker network inspect common-net &> /dev/null; then
        echo -e "$(printf "%-25s" "common-net") ${GREEN}Exists${NC}"
    else
        echo -e "$(printf "%-25s" "common-net") ${RED}Missing${NC}"
    fi

    if docker network inspect common-traefik-net &> /dev/null; then
        echo -e "$(printf "%-25s" "common-traefik-net") ${GREEN}Exists${NC}"
    else
        echo -e "$(printf "%-25s" "common-traefik-net") ${YELLOW}Not Created${NC}"
    fi

    echo ""
}

# Function to create networks
create_networks() {
    print_header "Creating Docker Networks"

    if docker network inspect common-net &> /dev/null; then
        print_warning "Network 'common-net' already exists"
    else
        docker network create common-net
        print_success "Created network 'common-net'"
    fi

    read -p "Create 'common-traefik-net' network? (y/n): " create_traefik
    if [[ "$create_traefik" =~ ^[Yy]$ ]]; then
        if docker network inspect common-traefik-net &> /dev/null; then
            print_warning "Network 'common-traefik-net' already exists"
        else
            docker network create common-traefik-net
            print_success "Created network 'common-traefik-net'"
        fi
    fi

    echo ""
}

# Function to inspect networks
inspect_networks() {
    print_header "Network Details"

    if docker network inspect common-net &> /dev/null; then
        echo -e "${CYAN}common-net:${NC}"
        docker network inspect common-net --format '  Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}}'
        docker network inspect common-net --format '  Gateway: {{range .IPAM.Config}}{{.Gateway}}{{end}}'
        local containers=$(docker network inspect common-net --format '{{range .Containers}}{{.Name}} {{end}}')
        if [ -n "$containers" ]; then
            echo "  Connected containers: $containers"
        else
            echo "  Connected containers: none"
        fi
        echo ""
    fi

    if docker network inspect common-traefik-net &> /dev/null; then
        echo -e "${CYAN}common-traefik-net:${NC}"
        docker network inspect common-traefik-net --format '  Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}}'
        docker network inspect common-traefik-net --format '  Gateway: {{range .IPAM.Config}}{{.Gateway}}{{end}}'
        local containers=$(docker network inspect common-traefik-net --format '{{range .Containers}}{{.Name}} {{end}}')
        if [ -n "$containers" ]; then
            echo "  Connected containers: $containers"
        else
            echo "  Connected containers: none"
        fi
        echo ""
    fi
}

# Function to show environment info
show_info() {
    print_header "Docker Commons Environment Information"

    echo -e "${CYAN}Docker:${NC}"
    docker --version
    echo ""

    echo -e "${CYAN}Docker Compose:${NC}"
    local compose_cmd=$(get_compose_cmd)
    $compose_cmd version
    echo ""

    echo -e "${CYAN}Networks:${NC}"
    if docker network inspect common-net &> /dev/null; then
        echo "  common-net: ${GREEN}✓${NC}"
    else
        echo "  common-net: ${RED}✗${NC}"
    fi
    if docker network inspect common-traefik-net &> /dev/null; then
        echo "  common-traefik-net: ${GREEN}✓${NC}"
    else
        echo "  common-traefik-net: ${YELLOW}-${NC}"
    fi
    echo ""

    echo -e "${CYAN}Configuration:${NC}"
    if [ -f ".env" ]; then
        echo "  .env file: ${GREEN}✓${NC}"
    else
        echo "  .env file: ${RED}✗${NC}"
    fi
    if [ -f "docker-compose.override.yml" ]; then
        echo "  docker-compose.override.yml: ${GREEN}✓${NC}"
    else
        echo "  docker-compose.override.yml: ${RED}✗${NC}"
    fi
    echo ""

    echo -e "${CYAN}Services:${NC}"
    local compose_cmd=$(get_compose_cmd)
    local total=$($compose_cmd config --services 2>/dev/null | wc -l)
    local running=$($compose_cmd ps -q 2>/dev/null | wc -l)
    echo "  Configured: $total"
    echo "  Running: $running"
    echo ""
}

# Function to run setup
run_setup() {
    if [ -x "./setup.sh" ]; then
        ./setup.sh
    else
        print_error "setup.sh not found or not executable"
        exit 1
    fi
}

# Main command handler
main() {
    # Check if running in correct directory
    if [ ! -f "docker-compose.yml" ]; then
        print_error "Please run this script from the docker-commons directory"
        exit 1
    fi

    local command="${1:-help}"
    shift 2>/dev/null || true

    case "$command" in
        # Setup & Configuration
        setup)
            run_setup
            ;;
        config)
            show_config
            ;;
        validate)
            validate_config
            ;;

        # Service Management
        start)
            start_services "$@"
            ;;
        stop)
            stop_services "$@"
            ;;
        restart)
            restart_services "$@"
            ;;
        status|ps)
            show_status
            ;;

        # Service Information
        list|ls)
            list_services
            ;;
        logs)
            show_logs "$@"
            ;;
        follow|tail)
            follow_logs "$@"
            ;;
        health)
            check_health "$@"
            ;;

        # Maintenance
        pull)
            pull_images "$@"
            ;;
        build)
            build_images "$@"
            ;;
        clean)
            clean_containers
            ;;
        prune)
            prune_resources
            ;;
        update)
            update_services
            ;;

        # Network Management
        networks)
            list_networks
            ;;
        network-create)
            create_networks
            ;;
        network-inspect)
            inspect_networks
            ;;

        # Information
        help|--help|-h)
            show_help
            ;;
        version|--version|-v)
            show_version
            ;;
        info)
            show_info
            ;;

        *)
            print_error "Unknown command: $command"
            echo ""
            print_info "Run './commons.sh help' to see available commands"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
