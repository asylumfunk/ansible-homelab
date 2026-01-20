ifeq (12,$(shell expr match '$(SDCARD_DEV)' '^/dev/mmcblk[0-9]'))
_SDCARD_DEV_BOOT = $(SDCARD_DEV)p1
_SDCARD_DEV_ROOT = $(SDCARD_DEV)p2
else
_SDCARD_DEV_BOOT = $(SDCARD_DEV)1
_SDCARD_DEV_ROOT = $(SDCARD_DEV)2
endif
_SDCARD_MNT_BOOT = mnt/boot
_SDCARD_MNT_ROOT = mnt/root

_MNT_NETWORK_CONFIG = $(_SDCARD_MNT_BOOT)/network-config
_MNT_USER_DATA = $(_SDCARD_MNT_BOOT)/user-data

CHECKSUMS ?= etc/sha256sum
_IMG_DATE ?= 2025-12-04
_IMG_ARCH ?= arm64
_IMG_OS ?= raspios
_IMG_RELEASE ?= trixie
_IMG_EDITION ?= -lite
_IMG_EDITION_ ?= $(subst -,_,$(_IMG_EDITION))
IMG ?= var/$(_IMG_DATE)-$(_IMG_OS)-$(_IMG_RELEASE)-$(_IMG_ARCH)$(_IMG_EDITION).img.xz
IMG_URL ?= https://downloads.raspberrypi.com/$(_IMG_OS)$(_IMG_EDITION_)_$(_IMG_ARCH)/images/$(_IMG_OS)$(_IMG_EDITION_)_$(_IMG_ARCH)-$(_IMG_DATE)/$(_IMG_DATE)-$(_IMG_OS)-$(_IMG_RELEASE)-$(_IMG_ARCH)$(_IMG_EDITION).img.xz
IMG_URL_SUM ?= $(IMG_URL).sha256
_DD_BS_WRITE ?= 32M
BACKUP_FIRST = 1

$(IMG):
	$(_WGET) --no-clobber --output-document='$(IMG)' '$(IMG_URL)'
	$(_WGET) --output-document=- '$(IMG_URL_SUM)' \
	| $(_AWK) '{print $$1, " var/"$$2}' \
	>>'$(CHECKSUMS)'

.PHONY: sdcard
ifeq (,$(BACKUP_FIRST))
sdcard: $(IMG)
else
sdcard: $(IMG) backup
endif
ifneq (,$(CHECKSUMS))
	# Verify checksums
	$(_BIN)/checksums '$(CHECKSUMS)' '$(IMG)'
endif
	$(_XZCAT) '$(IMG)' | $(_SUDO) $(_DD) of='$(SDCARD_DEV)' bs=$(_DD_BS_WRITE) status=progress conv=fdatasync
	$(_TEST) -e '$(_SDCARD_DEV_BOOT)'
	$(_SUDO) $(_MOUNT) '$(_SDCARD_DEV_BOOT)' '$(_SDCARD_MNT_BOOT)'
	$(_TEST) -e '$(_SDCARD_DEV_ROOT)'
	$(_SUDO) $(_MOUNT) '$(_SDCARD_DEV_ROOT)' '$(_SDCARD_MNT_ROOT)'
	$(_ENV) --ignore-environment \
		'WIFI_COUNTRY=$(WIFI_COUNTRY)' \
		'WIFI_NAME=$(WIFI_NAME)' \
		'WIFI_PASS=$(WIFI_PASS)' \
		$(_ENVSUBST) <etc/network-config \
	| $(_SUDO) $(_TEE) '$(_MNT_NETWORK_CONFIG)'
	$(_ENV) --ignore-environment \
		'HOST=$(HOST)' \
		'TIME_ZONE=$(TIME_ZONE)' \
		'WIFI_PASS=$(WIFI_PASS)' \
		'USER=$(USER)' \
		'PASSWD=$(_PASS_ENC)' \
		'LOCALE=$(LOCALE)' \
		'KEYBOARD_LAYOUT_LANG=$(KEYBOARD_LAYOUT_LANG)' \
		'SSH_ENABLED=$(SSH_ENABLED)' \
		$(_ENVSUBST) <etc/user-data \
	| $(_SUDO) $(_TEE) '$(_MNT_USER_DATA)'
	$(_SUDO) $(_UMOUNT) '$(_SDCARD_MNT_BOOT)'
	$(_SUDO) $(_UMOUNT) '$(_SDCARD_MNT_ROOT)'

.PHONY: mount
mount:
	$(_SUDO) $(_MOUNT) '$(_SDCARD_DEV_BOOT)' '$(_SDCARD_MNT_BOOT)'
	$(_SUDO) $(_MOUNT) '$(_SDCARD_DEV_ROOT)' '$(_SDCARD_MNT_ROOT)'

.PHONY: umount
umount:
	$(_SUDO) $(_UMOUNT) '$(_SDCARD_MNT_BOOT)'
	$(_SUDO) $(_UMOUNT) '$(_SDCARD_MNT_ROOT)'
