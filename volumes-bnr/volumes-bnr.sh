#!/usr/bin/env bash

set -e

# Function to display help
show_help() {
  echo "Description:"
  echo "  Use to backup named docker volumes in .tar file & restore them."
  echo ""
  echo "Usage:"
  echo "  ./volumes-bnr.sh backup BACKUP_FILE VOLUME_NAME CONTAINER_PATH [OPTION]"
  echo "  ./volumes-bnr.sh restore BACKUP_FILE VOLUME_NAME CONTAINER_PATH [OPTION]"
  echo ""
  echo "Arguments:"
  echo "  BACKUP_FILE       Name of the backup file. Must end with '.tar'"
  echo "  VOLUME_NAME       Name of the volume to backup/restore."
  echo "  CONTAINER_PATH    Path inside container to backup/restore."
  echo ""
  echo "Options:"
  echo "  -h        Display this help message"
  echo "  -v        Display version information"
}

# Check for arguments
while getopts "hv:" opt; do
  case $opt in
    h)
      show_help
      exit 0
      ;;
    v)
      echo "Volumes Backup & Restore Version 1.0"
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      show_help
      exit 1
      ;;
  esac
done

if [ -z "$2"]; then
  echo "BACKUP_FILE is missing."
  exit 1
fi

if [ -z "$3"]; then
  echo "VOLUME_NAME is missing."
  exit 1
fi

if [ -z "$4"]; then
  echo "CONTAINER_PATH is missing."
  exit 1
fi


run_backup() {
  echo 'Running backup.'
  echo '---------------'
  echo "Backup File: $1"
  echo "Named Volume: $2"
  echo "Container Path to backup: $3"

  local script_path=$(dirname "$(realpath "$0")")

  docker run --rm \
    -v ${script_path}/backups:/backups \
    -v $2:$3 \
    alpine:latest \
    tar -cvf /backups/$1 $3

  sudo chown $(id -u):$(id -g) ${script_path}/backups/$1

  echo 'Completed backup.'
  echo '-----------------'
}

run_restore() {
  echo 'Running restore.'
  echo '----------------'
  echo "Backup File: $1"
  echo "Named Volume: $2"
  echo "Container Path to restore: $3"

  local script_path=$(dirname "$(realpath "$0")")

  docker run --rm \
    -v ${script_path}/backups:/backups \
    -v $2:$3 \
    alpine:latest \
    tar -xvf /backups/$1 -C $3 --strip "1"

  echo 'Completed restore.'
  echo '------------------'
}

if [ "$1" = "backup" ]; then
  run_backup $2 $3 $4
elif [ "$1" = "restore" ]; then
  run_restore $2 $3 $4
else
  echo "Unknown command: $1"
  exit 1
fi
