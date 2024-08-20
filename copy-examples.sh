#!/bin/bash

# Copy docker compose example files
cp -n .env.example .env
cp -n docker-compose.override.example.yml docker-compose.override.yml

# Create {name}.env files from .example.env files in .envs directory
find .envs -type f | grep -E '[a-z-]+\.example\.env$' | cut -d'.' -f1 | while read prefix; do cp -n "${prefix}.example.env" "${prefix}.env"; done
