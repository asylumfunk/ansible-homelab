# ansible-homelab

## Use

### Backup an SD card

```sh
make dist
```

#### ... from a custom device path

This uses the device at /dev/sda, instead of the default, /dev/mmcblk0 .

```sh
make dist SDCARD_DEV=/dev/sda
```

#### ... with a custom archive name

Backup to `dist/backup_pihole.img.gz` instead of the default,
`dist/backup_sdcard.img.gz`.

```sh
make dist BACKUP_NAME=pihole
```

#### ... to a custom backup directory

Backup to `/tmp/backup_sdcard.img.gz`.

```sh
make dist DIST=/tmp
```
