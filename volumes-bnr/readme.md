# Volumes Backup & Restore (volumes-bnr)

Simple script to backup and restore docker's named volumes. Backups are done by tar.

## Requirements

* Bash
* Docker Engine v19+

## Usage

### To backup volume

```sh
./volumes-bnr.sh backup BACKUP_FILE VOLUME_NAME CONTAINER_PATH [OPTION]
```

### To restore volume

```sh
./volumes-bnr.sh restore BACKUP_FILE VOLUME_NAME CONTAINER_PATH [OPTION]
```

### Arguments Details

Name           | Details
---------------|-----------------------------------------------
BACKUP_FILE    | Name of the backup file. Must end with `.tar`
VOLUME_NAME    | Name of the volume to backup/restore.
CONTAINER_PATH | Path inside container to backup/restore.

### Options Details

Name  | Details
------|-----------------------------------------------
-h    | Display help information
-v    | Display version information
