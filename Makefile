ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SYSROOT := $(ROOT_DIR)/build/sysroot

include config.mk

export CFLAGS
export MAKEFLAGS

.PHONY: all clean distclean
all: coreboot.rom

include makefiles/helpers.mk

include makefiles/busybox.mk
include makefiles/coreboot.mk
include makefiles/cryptsetup.mk
include makefiles/kexec-tools.mk
include makefiles/linux.mk
include makefiles/musl.mk

clean:
	-rm -rf build bzImage coreboot.rom stamp/build-*

distclean:
	-rm -rf bzImage build src dist stamp