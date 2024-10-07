# NFS server

A simple local NFS server that you can use for testing purpose.

## Usage

After starting the container, you have to mount nfs server in your host machine.

To get container IP, you can use `ifconfig` or `hostname -I` or any other method you know.

To mount:

```sh
sudo mount -v -o vers=4,loud <container-ip>:/data /path/to/host/mount
```

**Important:** In your development machine, be sure to unmount the path, otherwise may cause issues.

To unmount:

```sh
sudo umount /path/to/host/mount
```
