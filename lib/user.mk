# Defaults, should usually be overridden
BACKUP_NAME ?= sdcard
USER ?= $(USER)
PASS ?= $(shell $(_ECHO) $(USER) | $(_REV))
HOST ?= homelab
DOMAIN ?= home.arpa
COUNTRY ?= US
SSH_ENABLED ?= 1
_HOST_FQDN = $(HOST).$(DOMAIN)
TIME_ZONE ?= $(shell cat /etc/timezone)
SDCARD_DEV ?= /dev/mmcblk0
