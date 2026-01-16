ifeq (12,$(shell expr match '$(SDCARD_DEV)' '^/dev/mmcblk[0-9]'))
_SDCARD_DEV_BOOT = $(SDCARD_DEV)p1
_SDCARD_DEV_ROOT = $(SDCARD_DEV)p2
else
_SDCARD_DEV_BOOT = $(SDCARD_DEV)1
_SDCARD_DEV_ROOT = $(SDCARD_DEV)2
endif
_SDCARD_MNT_BOOT = mnt/boot
_SDCARD_MNT_ROOT = mnt/root

_HOST_DEFAULT ?= raspberrypi
_PASS_ENC = $(shell $(_ECHO) '$(PASS)' | openssl passwd -6 -stdin)
_USER_CONF ?= $(_SDCARD_MNT_BOOT)/userconf.txt
_WIFI_CONF ?= $(_SDCARD_MNT_BOOT)/wpa_supplicant.conf

_ZONE_CONF = $(_SDCARD_MNT_ROOT)/etc/timezone
_HOSTS_FILE = $(_SDCARD_MNT_ROOT)/etc/hosts
_NMCLI_FILE = $(_SDCARD_MNT_ROOT)/var/lib/NetworkManager/NetworkManager.state
_HOST_FILE = $(_SDCARD_MNT_ROOT)/etc/hostname

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
sdcard: $(IMG) dist
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
ifneq (,$(USER))
	# Adding user:pass; $(USER):$(PASS)
	$(_ECHO) '$(USER):$(_PASS_ENC)' | $(_SUDO) $(_TEE) '$(_USER_CONF)'
endif
ifneq (,$(SSH_ENABLED))
	# RaspiOS will enable SSH access if this file exists
	$(_SUDO) $(_TOUCH) $(_SDCARD_MNT_BOOT)/ssh
endif
ifneq (,$(WIFI_NAME))
	# Enable WIFI
	{ \
		$(_ECHO) 'country=$(COUNTRY)'; \
		$(_ECHO) 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev'; \
		$(_ECHO) 'update_config=1'; \
		$(_ECHO) 'network={'; \
		$(_ECHO) '       ssid="$(WIFI_NAME)"'; \
		$(_ECHO) '       psk="$(WIFI_PASS)"'; \
		$(_ECHO) '       scan_ssid=1'; \
		$(_ECHO) '}'; \
	} | $(_SUDO) $(_TEE) '$(_WIFI_CONF)'
	$(_SUDO) $(_SED) -i "/^WirelessEnabled=/s/=false$$/=true/" '$(_NMCLI_FILE)'
	$(_ECHO) '#!/bin/sh' | $(_SUDO) $(_TEE) mnt/boot/firstrun.sh
	# systemd.run=/boot/firstrun.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target
	$(_ECHO) sudo raspi-config nonint do_wifi_country US | $(_SUDO) $(_TEE) -a mnt/boot/firstrun.sh
	$(_ECHO) sudo raspi-config nonint do_wifi_ssid_passphrase '$(WIFI_NAME)' '"$(WIFI_PASS)"' 0 0 | $(_SUDO) $(_TEE) -a mnt/boot/firstrun.sh
	# nmcli radio wifi on
endif
ifneq (,$(TIME_ZONE))
	# Update timezone
	$(_ECHO) '$(TIME_ZONE)' | $(_SUDO) $(_TEE) '$(_ZONE_CONF)'
endif
ifneq (,$(HOST))
	# Set hostname
	$(_ECHO) '$(HOST)' | $(_SUDO) $(_TEE) '$(_HOST_FILE)'
	$(_SUDO) $(_SED) -i "/127.0.1.1/s/$(_HOST_DEFAULT)/$(_HOST_FQDN) $(HOST)/" '$(_HOSTS_FILE)'
endif
	$(_SUDO) $(_UMOUNT) '$(_SDCARD_MNT_BOOT)'
	$(_SUDO) $(_UMOUNT) '$(_SDCARD_MNT_ROOT)'
