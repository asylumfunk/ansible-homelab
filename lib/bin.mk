# Helper scripts and utilities
_ANSIBLE_LINT ?= ansible-lint
_ANSIBLE_PLAYBOOK ?= ansible-playbook
_APT_GET ?= $(shell $(_COMMAND) -v apt-get)
_AWK ?= awk
_BIN ?= ./bin
_COMMAND ?= command
_DATE ?= date
_DD ?= dd
_ECHO ?= echo
_ENV ?= env
_ENVSUBST ?= envsubst
_GREP ?= grep
_GZIP ?= gzip
_LN ?= ln
_MOUNT ?= mount
_OPENSSL ?= openssl
_PIP ?= pip
_REV ?= $(shell $(_COMMAND) -v rev)
ifeq (,$(_REV))
_REV = cat
endif
_SED ?= sed
_SHA256SUM ?= sha256sum
_SUDO ?= sudo
_TEE ?= tee
_TEST ?= test
_TOUCH ?= touch
_UMOUNT ?= umount
_UNLINK ?= unlink
_WGET ?= wget
_XZCAT ?= xzcat
