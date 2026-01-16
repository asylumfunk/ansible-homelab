_SDCARD_DEV_BOOT = $(SDCARD_DEV)p1
_SDCARD_DEV_ROOT = $(SDCARD_DEV)p2
_SDCARD_MNT_BOOT = mnt/boot
_SDCARD_MNT_ROOT = mnt/root

_HOST_DEFAULT ?= raspberrypi
_PASS_ENC = $(shell $(_ECHO) '$(PASS)' | openssl passwd -6 -stdin)
_USER_CONF ?= $(_SDCARD_MNT_BOOT)/userconf.txt
_WIFI_CONF ?= $(_SDCARD_MNT_BOOT)/wpa_supplicant.conf

_ZONE_CONF = $(_SDCARD_MNT_ROOT)/etc/timezone
_HOSTS_FILE = $(_SDCARD_MNT_ROOT)/etc/hosts
_HOST_FILE = $(_SDCARD_MNT_ROOT)/etc/hostname

IMG ?= var/2025-12-04-raspios-trixie-arm64-lite.img.xz
CHECKSUMS ?= etc/sha256sum

.PHONY: requirements
requirements:
ifeq (,$(shell $(_COMMAND) -v $(_RPI_IMAGER)))
ifneq (,$(_APT_GET))
	$(_COMMAND) -v '$(_RPI_IMAGER)' >/dev/null \
	|| $(_SUDO) $(_APT_GET) install '$(_RPI_IMAGER)'
endif
endif

.PHONY: sdcard
sdcard: requirements
ifneq (,$(CHECKSUMS))
	$(_BIN)/checksums '$(CHECKSUMS)' '$(IMG)'
endif
	$(_SUDO) $(_RPI_IMAGER) --cli '$(IMG)' '$(SDCARD_DEV)'
	$(_SUDO) $(_MOUNT) '$(_SDCARD_DEV_BOOT)' '$(_SDCARD_MNT_BOOT)'
	$(_SUDO) $(_MOUNT) '$(_SDCARD_DEV_ROOT)' '$(_SDCARD_MNT_ROOT)'
ifneq (,$(USER))
	$(_ECHO) '$(USER):$(_PASS_ENC)' | $(_SUDO) $(_TEE) '$(_USER_CONF)'
endif
ifneq (,$(SSH_ENABLED))
	# RaspiOS will enable SSH access if this file exists
	$(_SUDO) $(_TOUCH) $(_SDCARD_MNT_BOOT)/ssh
endif
ifneq (,$(WIFI_NAME))
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
endif
ifneq (,$(TIME_ZONE))
	$(_ECHO) '$(TIME_ZONE)' | $(_SUDO) $(_TEE) '$(_ZONE_CONF)'
endif
ifneq (,$(HOST))
	$(_ECHO) '$(HOST)' | $(_SUDO) $(_TEE) '$(_HOST_FILE)'
	$(_SUDO) $(_SED) -i "/127.0.1.1/s/$(_HOST_DEFAULT)/$(_HOST_FQDN) $(HOST)/" '$(_HOSTS_FILE)'
endif
	$(_SUDO) $(_UMOUNT) '$(_SDCARD_MNT_BOOT)'
	$(_SUDO) $(_UMOUNT) '$(_SDCARD_MNT_ROOT)'
