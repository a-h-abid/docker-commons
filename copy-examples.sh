#!/usr/bin/bash

# Copy docker compose example files
cp .env.example .env
cp docker-compose.override.example.yml docker-compose.override.yml

# Create {name}.env files from .example.env files in .envs directory
find .envs/ -type f | grep -Po '([a-z\-]+)(?=.example.env)' | xargs -i cp .envs/{}.example.env .envs/{}.env
