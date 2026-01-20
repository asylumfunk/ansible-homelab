# Defaults, should usually be overridden
BACKUP_NAME ?= sdcard
USER ?= $(USER)
PASS ?= $(shell $(_ECHO) $(USER) | $(_REV))
_PASS_ENC = $(shell $(_ECHO) '$(PASS)' | $(_OPENSSL) passwd -6 -stdin)
GECOS ?= the default user account
HOST ?= homelab
DOMAIN ?= home.arpa
WIFI_COUNTRY ?= US
LOCALE ?= en_US
KEYBOARD_LAYOUT_LANG ?= us
SSH_ENABLED ?= true
ifneq (true, $(SSH_ENABLED))
SSH_ENABLED = false
endif
SSH_PASS_ENABLED ?= false
ifneq (true, $(SSH_PASS_ENABLED))
SSH_PASS_ENABLED = false
endif
SSH_ROOT_DISABLED ?= true
ifneq (false, $(SSH_ROOT_DISABLED))
SSH_ROOT_DISABLED = true
endif
_HOST_FQDN = $(HOST).$(DOMAIN)
TIME_ZONE ?= $(shell cat /etc/timezone)
ifeq (,$(TIME_ZONE))
TIME_ZONE = US/Pacific
endif
SDCARD_DEV ?= /dev/mmcblk0
