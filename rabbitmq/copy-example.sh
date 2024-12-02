#!/bin/bash

# Copy docker compose example files
cp --update=none .example.env .env
cp --update=none compose.rabbitmq.example.yml compose.rabbitmq.yml
cp --update=none rabbitmq.conf.example rabbitmq.conf
