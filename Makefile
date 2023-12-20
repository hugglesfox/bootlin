ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SYSROOT := $(ROOT_DIR)/build/sysroot

include config.mk

CFLAGS += --sysroot=$(SYSROOT) 
CFLAGS += -Wl,-rpath-link,$(SYSROOT)/usr/lib
CFLAGS += -Wl,-rpath-link,$(SYSROOT)/usr/lib64

PKG_CONFIG_PATH := $(SYSROOT)/usr/lib/pkgconfig:$(SYSROOT)/usr/lib64/pkgconfig

export CFLAGS
export MAKEFLAGS
export PKG_CONFIG_PATH

.PHONY: all clean distclean
all: coreboot.rom

include makefiles/helpers.mk

include makefiles/busybox.mk
include makefiles/cryptsetup.mk
include makefiles/kexec-tools.mk
include makefiles/musl.mk
include makefiles/flashrom.mk

include blobs/Makefile

TOOLS = $(BUSYBOX) $(CRYPTSETUP) $(FLASHROM) $(KEXEC)

include makefiles/linux.mk
include makefiles/coreboot.mk

clean:
	-rm -f coreboot.rom build/bzImage build/busybox

distclean:
	-rm -rf build/bzImage coreboot.rom build src dist stamp