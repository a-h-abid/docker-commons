#!/usr/bin/env bash

set -e

echo "=== Validating Docker Compose Files ==="

errors=0

# Return comma-separated dependency files for a given compose override file.
# Using a case statement for Bash 3.2 compatibility (macOS default shell).
get_deps() {
  case "$1" in
    docker-compose.override.apache-druid.yml)
      echo "docker-compose.override.apache-zookeeper.yml,docker-compose.override.postgres.yml"
      ;;
    docker-compose.override.redis-sentinel.yml)
      echo "docker-compose.override.redis.yml"
      ;;
    docker-compose.override.volumes.yml)
      echo "docker-compose.override.mysql.yml"
      ;;
    *)
      echo ""
      ;;
  esac
}

# Validate each docker-compose override file individually with the base file
for file in docker-compose.override.*.yml; do
  if [ "$file" = "docker-compose.override.example.yml" ]; then
    continue
  fi

  printf "Validating %-50s " "$file"

  # Build the compose file list
  compose_files="-f docker-compose.yml"

  # Add dependency files if needed
  file_deps=$(get_deps "$file")
  if [ -n "$file_deps" ]; then
    IFS=',' read -ra dep_files <<< "$file_deps"
    for dep in "${dep_files[@]}"; do
      compose_files="$compose_files -f $dep"
    done
  fi

  # Add traefik network file if needed
  if grep -q "common-traefik-net" "$file" 2>/dev/null; then
    if [[ "$compose_files" != *"traefik"* ]]; then
      compose_files="$compose_files -f docker-compose.override.traefik.yml"
    fi
  fi

  compose_files="$compose_files -f $file"

  # shellcheck disable=SC2086
  tmp_err=$(mktemp)
  if docker compose $compose_files config --quiet 2>"$tmp_err"; then
    echo "[OK]"
    rm -f "$tmp_err"
  else
    echo "[FAIL]"
    cat "$tmp_err"
    rm -f "$tmp_err"
    errors=$((errors + 1))
  fi
done

echo ""

# Validate that all .example.env files exist
echo "=== Validating Example Env Files ==="
env_example_files=(.envs/*.example.env)

if [ ! -e "${env_example_files[0]}" ]; then
  echo "No .envs/*.example.env files found [MISSING]"
  errors=$((errors + 1))
else
  for file in "${env_example_files[@]}"; do
    name=$(basename "$file" .example.env)
    printf "Checking %-50s " ".envs/$name.example.env"
    if [ -f "$file" ]; then
      echo "[OK]"
    else
      echo "[MISSING]"
      errors=$((errors + 1))
    fi
  done
fi
echo ""

if [ "$errors" -gt 0 ]; then
  echo "=== FAILED: $errors error(s) found ==="
  exit 1
else
  echo "=== All validations passed ==="
fi
