#!/bin/bash

# Change to the directory where this script lives
cd "$(dirname "$0")"

# Copy docker compose example files
cp --update=none .example.env .env
cp --update=none compose.rabbitmq.example.yaml compose.rabbitmq.yaml
cp --update=none rabbitmq.conf.example rabbitmq.conf
