#!/bin/bash

# Copy docker compose example files
cp --update=none .env.example .env
cp --update=none docker-compose.override.example.yml docker-compose.override.yml

# Create {name}.env files from .example.env files in .envs directory
if [[ -f /etc/issue ]]; then
  # If the file exists, it's likely a Linux system
  find .envs/ -type f | grep -Po '([a-z\-]+)(?=.example.env)' | xargs -i cp --update=none .envs/{}.example.env .envs/{}.env
elif [[ -f /System/Library/CoreServices/SystemVersion.plist ]]; then
  # If the macOS-specific SystemVersion.plist file exists, it's likely a macOS system
  find .envs -type f | grep -E '[a-z-]+\.example\.env$' | cut -d'.' -f1 | while read prefix; do cp --update=none "${prefix}.example.env" "${prefix}.env"; done
fi
