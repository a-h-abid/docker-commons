# Docker Commons

This project has my personal common docker scripts that can be used centrally or reusable by multiple projects.

## Tested Docker Version

- Docker Engine v19.03+
- Docker Compose v1.25+

## Usage

- Clone
- Copy `./.env.example` file to `./.env` and then update it per your need. More specifically update the `COMPOSE_FILE` env for the services you want to use.
- Copy `./docker-compose.override.example.yml` file to `./docker-compose.override.yml` and then update it with components as per your need.
- Copy all example files in `./envs` to `./envs/[name].env` file and then update them per your need.
    - Ex. `cp ./.envs/mysql.example.env ./.envs/mysql.env`.
- Run `docker network create common-net`
- Run `docker-compose up -d` or `docker-compose up -d <service1> <service2> ...`


## NFS server after up

Mount nfs server in your host machine. To get container IP, you can use `ifconfig` or `hostname -I` or any other method you know.

```
sudo mount -v -o vers=4,loud <container-ip>:/ /path/to/mount
```

**Important:** In your development machine, be sure to unmount the path, otherwise may cause issues. To unmount:

```
sudo umount /path/to/mount
```

## License

This project is licensed under the terms of the MIT license.
