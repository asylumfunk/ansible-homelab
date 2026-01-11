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

### Write RaspiOS to SDcard

```sh
make sdcard
```

#### ... with wifi access

```sh
make sdcard WIFI_NAME=MyLanName WIFI_PASS=foobar
```

#### ... with a custom local user

```sh
make sdcard USER=my_user_name PASS=my_user_pass
```

#### ... with a custom time zone

```sh
make sdcard TIME_ZONE=UTC
```

#### ... with a custom hostname

```sh
make sdcard HOST=my_user_hostname
```

#### ... without _any_ modifications

```sh
make sdcard SSH_ENABLED= WIFI_NAME= USER= TIME_ZONE= CHECKSUMS= HOST=
```
