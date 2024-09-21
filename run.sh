#!/usr/bin/env bash

set -e

availableServices=(adminer)
availableServices+=(volumes-bnr)

showServicesList() {
  local columns=4
  local width=20
  local rows=$(( (${#availableServices[@]} + columns - 1) / columns ))

  printf "%s\n" "------------------------------------------"
  printf "%s %s %s\n" "             " "Services List" "              "
  printf "%s\n" "========================================="

  for ((i=0; i<rows; i++)); do
      for ((j=0; j<columns; j++)); do
          local index=$(( i + j * rows ))
          if [ $index -lt ${#availableServices[@]} ]; then
              printf "%-${width}s" "${availableServices[index]}"
          fi
      done
      echo
  done

  printf "%s\n\n" "========================================="
}

showServicesList
