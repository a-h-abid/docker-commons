# Docker Commons

This project has my personal common docker scripts that can be used centrally or reusable by multiple projects.

## Tested Docker Version

- Docker Engine v19.03+
- Docker Compose v1.25+

## Usage

- Clone
- Copy `./.env.example` file to `./.env` and then update it per your need. More specifically update the `COMPOSE_FILE` env for the services you want to use.
- Copy `./docker-compose.override.example.yml` file to `./docker-compose.override.yml` and then update it per your need.
- Copy all example files in `./envs` to `./envs/[name].env` file and then update them per your need.
    - Ex. `cp ./.envs/mysql.example.env ./.envs/mysql.env`.
- Run `docker network create common-net`
- Run `docker-compose up -d` or `docker-compose up -d <service1> <service2> ...`

## License

This project is licensed under the terms of the MIT license.
