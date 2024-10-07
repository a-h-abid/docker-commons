#!/usr/bin/env bash

set -e

availableServices=(adminer)
availableServices+=(nfs-server)
availableServices+=(redis)
availableServices+=(redis-insight)
availableServices+=(redis-slave)
availableServices+=(redis-sentiner)
availableServices+=(traefik)

showServicesList() {
  local columns=6
  local width=20
  local rows=$(( (${#availableServices[@]} + columns - 1) / columns ))

  printf "%s\n" "=========================================="
  printf "%s\n" "              Services List               "
  printf "%s\n" "=========================================="

  for ((i=0; i<rows; i++)); do
      for ((j=0; j<columns; j++)); do
          local index=$(( i + j * rows ))
          if [ $index -lt ${#availableServices[@]} ]; then
              printf "%-${width}s" "${availableServices[index]}"
          fi
      done
      echo
  done

  printf "%s\n\n" "------------------------------------------"
}

showServicesList
