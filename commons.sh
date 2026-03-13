#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# A small, opinionated helper to make Docker Commons easier to set up and run.
# Tasks it handles:
# - Copy example env/override files (without overwriting user changes)
# - Build a COMPOSE_FILE string for selected services
# - Create the shared Docker networks before bringing services up
# - Wrap common docker compose commands (up/down/ps/logs/pull)

DEFAULT_SERVICES=(adminer mysql redis)
SERVICE_KEYS=()
SERVICE_PATHS=()
NEEDS_TRAEFIK=0

register_service() {
  local key="$1" path="$2"

  for i in "${!SERVICE_KEYS[@]}"; do
    if [ "${SERVICE_KEYS[$i]}" = "$key" ]; then
      return
    fi
  done

  SERVICE_KEYS+=("$key")
  SERVICE_PATHS+=("$path")
}

load_services() {
  SERVICE_KEYS=()
  SERVICE_PATHS=()

  # Root-level override fragments
  while IFS= read -r file; do
    local name
    name="${file##*/docker-compose.override.}"
    name="${name%.yml}"
    name="${name%.yaml}"
    if [ "$name" = "example" ]; then
      continue
    fi
    register_service "$name" "$file"
  done < <(find "$ROOT_DIR" -maxdepth 1 -type f -name 'docker-compose.override.*.yml' -o -name 'docker-compose.override.*.yaml' | sort)

  # Per-service example fragments that are kept beside the service directories
  while IFS= read -r file; do
    local base name
    base="$(basename "$file")"
    name="${base#compose.}"
    name="${name%.example.yml}"
    name="${name%.example.yaml}"
    register_service "$name" "$file"
  done < <(find "$ROOT_DIR" -maxdepth 2 -type f \( -name 'compose.*.example.yml' -o -name 'compose.*.example.yaml' \) | sort)
}

find_service_path() {
  local key="$1"
  for i in "${!SERVICE_KEYS[@]}"; do
    if [ "${SERVICE_KEYS[$i]}" = "$key" ]; then
      echo "${SERVICE_PATHS[$i]}"
      return 0
    fi
  done
  return 1
}

join_with_sep() {
  local sep="$1"
  shift
  local IFS="$sep"
  echo "$*"
}

update_env_value() {
  local key="$1" value="$2" file="$3"

  if [ ! -f "$file" ]; then
    printf '%s=%s\n' "$key" "$value" >"$file"
    return
  fi

  if grep -q "^${key}=" "$file"; then
    local tmp
    tmp="$(mktemp)"
    awk -v k="$key" -v v="$value" 'BEGIN{FS=OFS="="} $1==k {$0=k "=" v} {print}' "$file" >"$tmp"
    mv "$tmp" "$file"
  else
    printf '\n%s=%s\n' "$key" "$value" >>"$file"
  fi
}

read_env_value() {
  local key="$1" file="$2"
  if [ ! -f "$file" ]; then
    return
  fi

  local line
  line="$(grep -E "^${key}=" "$file" | tail -n 1 || true)"
  echo "${line#*=}"
}

parse_services_arg() {
  local raw="$1"
  raw="${raw//,/ }"
  PARSED_SERVICES=()
  for item in $raw; do
    PARSED_SERVICES+=("$item")
  done
}

compose_value_for_services() {
  local services=("$@")
  local sep="${COMPOSE_PATH_SEPARATOR:-:}"
  local files=("docker-compose.yml")
  NEEDS_TRAEFIK=0

  for svc in "${services[@]}"; do
    local path
    path="$(find_service_path "$svc")" || {
      echo "Unknown service: $svc" >&2
      exit 1
    }
    files+=("$path")
    if [ "$svc" = "traefik" ]; then
      NEEDS_TRAEFIK=1
    fi
  done

  if [ -f "$ROOT_DIR/docker-compose.override.yml" ]; then
    files+=("docker-compose.override.yml")
  fi

  join_with_sep "$sep" "${files[@]}"
}

ensure_network() {
  local name="$1"
  if ! command -v docker >/dev/null 2>&1; then
    echo "docker is not available; skipping creation of network $name" >&2
    return
  fi

  if docker network inspect "$name" >/dev/null 2>&1; then
    return
  fi

  echo "Creating docker network: $name"
  docker network create "$name" >/dev/null
}

ensure_networks() {
  ensure_network "common-net"
  if [ "$NEEDS_TRAEFIK" -eq 1 ]; then
    ensure_network "common-traefik-net"
  fi
}

require_compose_file_value() {
  local services_override=("$@")
  local value

  if [ ${#services_override[@]} -gt 0 ]; then
    value="$(compose_value_for_services "${services_override[@]}")"
  else
    value="$(read_env_value "COMPOSE_FILE" "$ROOT_DIR/.env")"
    if [ -z "$value" ]; then
      echo "COMPOSE_FILE is not set. Run './commons.sh init' first." >&2
      exit 1
    fi
    case "$value" in
      *traefik*) NEEDS_TRAEFIK=1 ;;
      *) NEEDS_TRAEFIK=0 ;;
    esac
  fi

  echo "$value"
}

cmd_services() {
  load_services
  local lines=()
  for i in "${!SERVICE_KEYS[@]}"; do
    lines+=("${SERVICE_KEYS[$i]}|${SERVICE_PATHS[$i]}")
  done

  printf "Available services (use names with --services):\n"
  printf "%s\n" "${lines[@]}" | sort | while IFS='|' read -r name path; do
    printf "  - %-18s %s\n" "$name" "$path"
  done
}

cmd_init() {
  load_services

  local use_all=0 dry_run=0
  local services=()

  while [ $# -gt 0 ]; do
    case "$1" in
      --services)
        parse_services_arg "$2"
        services=("${PARSED_SERVICES[@]}")
        shift 2
        ;;
      --all)
        use_all=1
        shift
        ;;
      --dry-run)
        dry_run=1
        shift
        ;;
      *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac
  done

  if [ "$use_all" -eq 1 ]; then
    services=("${SERVICE_KEYS[@]}")
  elif [ ${#services[@]} -eq 0 ]; then
    services=("${DEFAULT_SERVICES[@]}")
  fi

  if [ ${#services[@]} -eq 0 ]; then
    echo "No services selected." >&2
    exit 1
  fi

  local compose_value
  compose_value="$(compose_value_for_services "${services[@]}")"

  if [ "$dry_run" -eq 1 ]; then
    printf "Would set COMPOSE_FILE to:\n%s\n" "$compose_value"
    printf "Services: %s\n" "${services[*]}"
    exit 0
  fi

  if [ -x "$ROOT_DIR/copy-examples.sh" ]; then
    "$ROOT_DIR/copy-examples.sh"
  fi

  update_env_value "COMPOSE_FILE" "$compose_value" "$ROOT_DIR/.env"
  update_env_value "COMPOSE_PATH_SEPARATOR" "${COMPOSE_PATH_SEPARATOR:-:}" "$ROOT_DIR/.env"

  printf "Configured services: %s\n" "${services[*]}"
  printf "Updated COMPOSE_FILE in .env\n"
  printf "Next: ./commons.sh up\n"
}

cmd_up() {
  load_services
  local services_override=()

  while [ $# -gt 0 ]; do
    case "$1" in
      --services)
        parse_services_arg "$2"
        services_override=("${PARSED_SERVICES[@]}")
        shift 2
        ;;
      --all)
        services_override=("${SERVICE_KEYS[@]}")
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  local compose_value
  compose_value="$(require_compose_file_value "${services_override[@]}")"
  ensure_networks

  COMPOSE_FILE="$compose_value" docker compose up -d "$@"
}

cmd_down() {
  load_services
  local compose_value
  compose_value="$(require_compose_file_value)"
  COMPOSE_FILE="$compose_value" docker compose down "$@"
}

cmd_ps() {
  load_services
  local compose_value
  compose_value="$(require_compose_file_value)"
  COMPOSE_FILE="$compose_value" docker compose ps "$@"
}

cmd_logs() {
  load_services
  local compose_value
  compose_value="$(require_compose_file_value)"
  COMPOSE_FILE="$compose_value" docker compose logs "$@"
}

cmd_pull() {
  load_services
  local compose_value
  compose_value="$(require_compose_file_value)"
  COMPOSE_FILE="$compose_value" docker compose pull "$@"
}

cmd_help() {
  cat <<'USAGE'
Usage: ./commons.sh <command> [options]

Commands:
  init [--services "mysql redis"] [--all] [--dry-run]  Copy example files and set COMPOSE_FILE
  services                                             List service keys and their compose fragments
  up [--services "mysql redis"|--all] [compose args]   Bring services up (creates networks automatically)
  down [compose args]                                  Stop and remove running services
  ps                                                   Show running services
  logs [service]                                       Tail logs for one/all services
  pull                                                 Pull images for the current COMPOSE_FILE
  help                                                 Show this message

Notes:
  - Run './commons.sh init' first to create .env/.envs files and set COMPOSE_FILE.
  - Use '--services' to quickly switch which compose fragments are active without editing .env manually.
USAGE
}

main() {
  local cmd="${1:-help}"
  shift || true

  case "$cmd" in
    init) cmd_init "$@" ;;
    services) cmd_services "$@" ;;
    up) cmd_up "$@" ;;
    down) cmd_down "$@" ;;
    ps) cmd_ps "$@" ;;
    logs) cmd_logs "$@" ;;
    pull) cmd_pull "$@" ;;
    help|--help|-h) cmd_help ;;
    *)
      echo "Unknown command: $cmd" >&2
      cmd_help
      exit 1
      ;;
  esac
}

main "$@"
