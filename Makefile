ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SYSROOT := $(ROOT_DIR)/build/sysroot

include config.mk

export CFLAGS
export MAKEFLAGS

.PHONY: all clean distclean
all: coreboot.rom

include makefiles/helpers.mk

include makefiles/busybox.mk
include makefiles/cryptsetup.mk
include makefiles/kexec-tools.mk
include makefiles/glibc.mk
include makefiles/flashrom.mk

include blobs/Makefile

TOOLS = $(BUSYBOX) $(CRYPTSETUP) $(FLASHROM) $(KEXEC)

include makefiles/linux.mk
include makefiles/coreboot.mk

clean:
	-rm -f coreboot.rom build/bzImage build/busybox

distclean:
	-rm -rf build/bzImage coreboot.rom build src dist stamp
