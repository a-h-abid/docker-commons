#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script version
VERSION="1.0.0"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}║            Docker Commons - Interactive Setup              ║${NC}"
echo -e "${BLUE}║                    Version ${VERSION}                         ║${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

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

# Function to check prerequisites
check_prerequisites() {
    echo -e "\n${BLUE}=== Checking Prerequisites ===${NC}\n"

    local all_good=true

    # Check Docker
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version | awk '{print $3}' | sed 's/,//')
        print_success "Docker installed: $docker_version"
    else
        print_error "Docker is not installed"
        all_good=false
    fi

    # Check Docker Compose
    if docker compose version &> /dev/null; then
        local compose_version=$(docker compose version | awk '{print $4}')
        print_success "Docker Compose installed: $compose_version"
    elif command -v docker-compose &> /dev/null; then
        local compose_version=$(docker-compose --version | awk '{print $4}' | sed 's/,//')
        print_success "Docker Compose installed: $compose_version"
        print_warning "Consider upgrading to Docker Compose V2 (docker compose)"
    else
        print_error "Docker Compose is not installed"
        all_good=false
    fi

    # Check Docker daemon
    if docker info &> /dev/null; then
        print_success "Docker daemon is running"
    else
        print_error "Docker daemon is not running"
        all_good=false
    fi

    if [ "$all_good" = false ]; then
        echo ""
        print_error "Some prerequisites are missing. Please install them and try again."
        exit 1
    fi

    echo ""
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Function to create config files from examples
create_config_files() {
    echo -e "\n${BLUE}=== Creating Configuration Files ===${NC}\n"

    local os_type=$(detect_os)

    # Copy main .env file
    if [ ! -f .env ]; then
        cp .env.example .env
        print_success "Created .env file"
    else
        print_warning ".env file already exists, skipping"
    fi

    # Copy docker-compose.override.yml
    if [ ! -f docker-compose.override.yml ]; then
        cp docker-compose.override.example.yml docker-compose.override.yml
        print_success "Created docker-compose.override.yml"
    else
        print_warning "docker-compose.override.yml already exists, skipping"
    fi

    # Create environment files in .envs directory
    local env_count=0
    for example_file in .envs/*.example.env; do
        if [ -f "$example_file" ]; then
            local env_file="${example_file%.example.env}.env"
            if [ ! -f "$env_file" ]; then
                cp "$example_file" "$env_file"
                env_count=$((env_count + 1))
            fi
        fi
    done
    if [ $env_count -gt 0 ]; then
        print_success "Created $env_count service environment files in .envs/"
    fi

    # Run service-specific copy scripts
    if [ -x "./rabbitmq/copy-example.sh" ]; then
        ./rabbitmq/copy-example.sh &> /dev/null
        print_success "Created RabbitMQ configuration files"
    fi

    # Set path separator based on OS
    local path_separator=":"
    if [ "$os_type" = "windows" ]; then
        path_separator=";"
        # Update COMPOSE_PATH_SEPARATOR in .env file
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|COMPOSE_PATH_SEPARATOR=:|COMPOSE_PATH_SEPARATOR=;|g" .env
        else
            sed -i "s|COMPOSE_PATH_SEPARATOR=:|COMPOSE_PATH_SEPARATOR=;|g" .env
        fi
        print_info "Set path separator to ';' for Windows"
    fi

    echo ""
}

# Service categories and dependencies
declare -A SERVICE_CATEGORIES
declare -A SERVICE_DEPS
declare -A SERVICE_BUILD_REQUIRED

# Initialize service metadata
init_service_metadata() {
    # Databases
    SERVICE_CATEGORIES["mysql"]="database"
    SERVICE_CATEGORIES["postgres"]="database"
    SERVICE_CATEGORIES["mongo"]="database"
    SERVICE_CATEGORIES["cassandra"]="database"
    SERVICE_CATEGORIES["cassandra-dse"]="database"
    SERVICE_CATEGORIES["oracle"]="database"

    # Cache / In-Memory
    SERVICE_CATEGORIES["redis"]="cache"
    SERVICE_CATEGORIES["dragonfly"]="cache"
    SERVICE_CATEGORIES["redis-stack"]="cache"
    SERVICE_CATEGORIES["redisearch"]="cache"
    SERVICE_CATEGORIES["redis-sentinel"]="cache"

    # Message Queues
    SERVICE_CATEGORIES["rabbitmq"]="queue"

    # Search & Analytics
    SERVICE_CATEGORIES["elasticsearch"]="search"
    SERVICE_CATEGORIES["apache-druid"]="analytics"
    SERVICE_CATEGORIES["apache-zookeeper"]="coordination"

    # Management UIs
    SERVICE_CATEGORIES["adminer"]="ui"
    SERVICE_CATEGORIES["portainer"]="ui"
    SERVICE_CATEGORIES["kibana"]="ui"
    SERVICE_CATEGORIES["grafana"]="ui"
    SERVICE_CATEGORIES["redis-insight"]="ui"

    # Proxy / Gateway
    SERVICE_CATEGORIES["traefik"]="proxy"

    # Mail Testing
    SERVICE_CATEGORIES["maildev"]="mail"
    SERVICE_CATEGORIES["mailhog"]="mail"

    # Storage
    SERVICE_CATEGORIES["minio"]="storage"
    SERVICE_CATEGORIES["nfs-server"]="storage"
    SERVICE_CATEGORIES["sftp"]="storage"

    # Other Services
    SERVICE_CATEGORIES["jaeger"]="tracing"
    SERVICE_CATEGORIES["jenkins"]="cicd"
    SERVICE_CATEGORIES["flagr"]="feature-flags"
    SERVICE_CATEGORIES["ldap"]="directory"
    SERVICE_CATEGORIES["blackfire"]="profiling"
    SERVICE_CATEGORIES["fluentd"]="logging"

    # Service dependencies
    SERVICE_DEPS["redis-sentinel"]="redis"
    SERVICE_DEPS["apache-druid"]="apache-zookeeper postgres"
    SERVICE_DEPS["kibana"]="elasticsearch"
    SERVICE_DEPS["redis-insight"]="redis"
    SERVICE_DEPS["volumes"]="mysql"

    # Services requiring build
    SERVICE_BUILD_REQUIRED["cassandra-dse"]="yes"
    SERVICE_BUILD_REQUIRED["elasticsearch"]="yes"
    SERVICE_BUILD_REQUIRED["kibana"]="yes"
    SERVICE_BUILD_REQUIRED["flagr"]="yes"
    SERVICE_BUILD_REQUIRED["fluentd"]="yes"
    SERVICE_BUILD_REQUIRED["oracle"]="yes"
    SERVICE_BUILD_REQUIRED["redisearch"]="yes"
}

# Function to show service selection menu
select_services() {
    echo -e "\n${BLUE}=== Service Selection ===${NC}\n"

    print_info "Select services to enable (you can always change this later)"
    echo ""

    # Common preset configurations
    echo "Quick Start Presets:"
    echo "  1) Essential (MySQL, Redis, Adminer)"
    echo "  2) Full Stack (MySQL, Redis, RabbitMQ, Elasticsearch, Adminer)"
    echo "  3) Minimal (Just Docker network setup, no services)"
    echo "  4) Custom (Choose services manually)"
    echo "  5) All Services (Enable everything)"
    echo ""

    read -p "Select preset [1-5]: " preset_choice

    local selected_services=()

    case $preset_choice in
        1)
            selected_services=("mysql" "redis" "adminer")
            print_info "Selected: Essential preset"
            ;;
        2)
            selected_services=("mysql" "redis" "rabbitmq" "elasticsearch" "adminer")
            print_info "Selected: Full Stack preset"
            ;;
        3)
            print_info "Selected: Minimal setup (network only)"
            ;;
        4)
            selected_services=($(select_custom_services))
            ;;
        5)
            # Enable all available services
            selected_services=("adminer" "mysql" "redis" "postgres" "mongo" "rabbitmq" "elasticsearch" "maildev" "mailhog" "traefik")
            print_info "Selected: All Services"
            ;;
        *)
            print_warning "Invalid choice. Using Essential preset."
            selected_services=("mysql" "redis" "adminer")
            ;;
    esac

    # Add dependencies
    local final_services=()
    for service in "${selected_services[@]}"; do
        final_services+=("$service")
        # Add dependencies if they exist
        if [ -n "${SERVICE_DEPS[$service]}" ]; then
            for dep in ${SERVICE_DEPS[$service]}; do
                if [[ ! " ${final_services[@]} " =~ " ${dep} " ]]; then
                    final_services+=("$dep")
                    print_info "Added dependency: $dep (required by $service)"
                fi
            done
        fi
    done

    # Update COMPOSE_FILE in .env
    if [ ${#final_services[@]} -gt 0 ]; then
        update_compose_file_env "${final_services[@]}"
    fi

    echo ""
}

# Function for custom service selection
select_custom_services() {
    local services=("adminer" "mysql" "postgres" "redis" "mongo" "rabbitmq" "elasticsearch" "maildev" "mailhog" "traefik" "minio" "cassandra" "dragonfly" "flagr" "jaeger" "grafana")
    local selected=()

    echo ""
    echo "Available services (enter numbers separated by spaces, e.g., '1 2 5'):"
    for i in "${!services[@]}"; do
        printf "  %2d) %s\n" $((i+1)) "${services[$i]}"
    done
    echo ""

    read -p "Enter your choices: " choices

    for choice in $choices; do
        local idx=$((choice-1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#services[@]} ]; then
            selected+=("${services[$idx]}")
        fi
    done

    echo "${selected[@]}"
}

# Function to update COMPOSE_FILE in .env
update_compose_file_env() {
    local services=("$@")
    local compose_files="docker-compose.yml"

    # Map service names to compose file names
    for service in "${services[@]}"; do
        local compose_file="docker-compose.override.${service}.yml"
        if [ -f "$compose_file" ]; then
            compose_files="${compose_files}:${compose_file}"
        fi
    done

    # Always add the main override file at the end
    compose_files="${compose_files}:docker-compose.override.yml"

    # Update .env file
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|^COMPOSE_FILE=.*|COMPOSE_FILE=${compose_files}|" .env
    else
        sed -i "s|^COMPOSE_FILE=.*|COMPOSE_FILE=${compose_files}|" .env
    fi

    print_success "Updated COMPOSE_FILE in .env"
}

# Function to create Docker networks
create_networks() {
    echo -e "\n${BLUE}=== Creating Docker Networks ===${NC}\n"

    # Create common-net network
    if docker network inspect common-net &> /dev/null; then
        print_warning "Network 'common-net' already exists"
    else
        docker network create common-net
        print_success "Created network 'common-net'"
    fi

    # Ask if user wants Traefik network
    read -p "Do you plan to use Traefik? (y/n): " use_traefik
    if [[ "$use_traefik" =~ ^[Yy]$ ]]; then
        if docker network inspect common-traefik-net &> /dev/null; then
            print_warning "Network 'common-traefik-net' already exists"
        else
            docker network create common-traefik-net
            print_success "Created network 'common-traefik-net'"
        fi
    fi

    echo ""
}

# Function to pull/build images
handle_images() {
    echo -e "\n${BLUE}=== Docker Images ===${NC}\n"

    read -p "Do you want to pull Docker images now? (recommended) (y/n): " pull_images
    if [[ "$pull_images" =~ ^[Yy]$ ]]; then
        print_info "Pulling Docker images... (this may take a while)"
        if docker compose pull 2>&1 | grep -v "Pulling"; then
            print_success "Docker images pulled successfully"
        else
            print_warning "Some images could not be pulled (this is normal for custom-built services)"
        fi
    else
        print_info "Skipping image pull. You can run 'docker compose pull' later."
    fi

    # Check if any selected services require building
    echo ""
    read -p "Do you want to build custom images now? (required for some services) (y/n): " build_images
    if [[ "$build_images" =~ ^[Yy]$ ]]; then
        print_info "Building custom Docker images... (this may take several minutes)"
        if docker compose build 2>&1; then
            print_success "Docker images built successfully"
        else
            print_warning "Some images could not be built. You may need to build specific services later."
        fi
    else
        print_info "Skipping image build. Some services may require 'docker compose build <service>' before use."
    fi

    echo ""
}

# Function to show completion message and next steps
show_completion() {
    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}║              Setup Completed Successfully!                 ║${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}\n"

    echo -e "${BLUE}Next Steps:${NC}\n"

    echo "1. Review and customize your configuration:"
    echo "   - Edit .env file for global settings"
    echo "   - Edit docker-compose.override.yml for service-specific settings"
    echo "   - Edit files in .envs/ directory for individual service configs"
    echo ""

    echo "2. Start your services:"
    echo "   ${GREEN}./commons.sh start${NC}        # Start all configured services"
    echo "   ${GREEN}./commons.sh start mysql${NC}  # Start specific service(s)"
    echo ""

    echo "3. Manage your services:"
    echo "   ${GREEN}./commons.sh status${NC}       # Check service status"
    echo "   ${GREEN}./commons.sh stop${NC}         # Stop all services"
    echo "   ${GREEN}./commons.sh logs mysql${NC}   # View service logs"
    echo "   ${GREEN}./commons.sh help${NC}         # See all available commands"
    echo ""

    echo "4. Traditional Docker Compose commands still work:"
    echo "   ${GREEN}docker compose up -d${NC}      # Start all services"
    echo "   ${GREEN}docker compose ps${NC}         # List running services"
    echo "   ${GREEN}docker compose down${NC}       # Stop all services"
    echo ""

    print_info "For more information, check the readme.md file"
    echo ""
}

# Main execution
main() {
    init_service_metadata

    # Check if running in script directory
    if [ ! -f "docker-compose.yml" ]; then
        print_error "Please run this script from the docker-commons directory"
        exit 1
    fi

    check_prerequisites
    create_config_files
    select_services
    create_networks
    handle_images
    show_completion
}

# Run main function
main "$@"
