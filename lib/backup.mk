DIST ?= dist
_BACKUP_PREFIX ?= backup
_BACKUP_NAME_FULL ?= $(DIST)/$(_BACKUP_PREFIX)_$(BACKUP_NAME)
_BACKUP_LATEST = $(_BACKUP_NAME_FULL).img.gz
_BACKUP_VERSION = $(_BACKUP_NAME_FULL)_$(shell $(_DATE) '+%Y%m%d-%H%M').img.gz

## Copy contents of an unmounted disk device, compress, and save to disk
$(_BACKUP_VERSION):
	$(_SUDO) $(_DD) if='$(SDCARD_DEV)' bs=4M status=progress \
	| $(_GZIP) --to-stdout >'$(@)'

## Tag the latest backup
$(_BACKUP_LATEST): $(_BACKUP_VERSION)
	$(_TEST) \! -e '$(@)' || $(_UNLINK) '$(@)'
	$(_LN) '$(<)' '$(@)'

.PHONY: dist $(DIST)
dist: $(DEST)  ## Backup disk before overwriting
$(DIST): $(_BACKUP_LATEST)
