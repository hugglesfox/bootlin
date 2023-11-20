ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BOARD := qemu

CFLAGS := -march=x86-64 -Os
MAKEFLAGS := -j10

export CFLAGS
export MAKEFLAGS

LINUX_DIR=linux-6.6.1
LINUX_TARBALL=$(LINUX_DIR).tar.xz
LINUX_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)

UROOT_DIR=u-root-0.11.0
UROOT_TARBALL=$(UROOT_DIR).tar.gz
UROOT_URL=https://github.com/u-root/u-root/archive/refs/tags/v0.11.0.tar.gz

COREBOOT_DIR=coreboot-4.21
COREBOOT_TARBALL=$(COREBOOT_DIR).tar.xz
COREBOOT_URL=https://coreboot.org/releases/$(COREBOOT_TARBALL)

define fetch
	mkdir -p dist src stamp
	cd dist && wget -O $($(1)_TARBALL) $($(1)_URL)
	cd src && tar -xvf ../dist/$($(1)_TARBALL)
endef

.PHONY: all clean distclean kernelmenuconfig

all: coreboot.rom

stamp/fetch-linux:
	$(call fetch,LINUX)
	touch $@

stamp/fetch-uroot:
	$(call fetch,UROOT)
	touch $@

stamp/fetch-coreboot:
	$(call fetch,COREBOOT)
	touch $@

stamp/build-uroot: stamp/fetch-uroot
	cd src/$(UROOT_DIR) && go build
	touch $@

stamp/build-coreboot-toolchain: stamp/fetch-coreboot
	cd src/$(COREBOOT_DIR) && $(MAKE) crossgcc-i386 CPUS=8
	touch $@

initramfs.cpio.gz: stamp/build-uroot
	cd src/$(UROOT_DIR) && ./u-root -o $(ROOT_DIR)/initramfs.cpio boot core
	gzip -f initramfs.cpio

bzImage: stamp/fetch-linux
	cp configs/$(BOARD)_kernel.config src/$(LINUX_DIR)/.config
	cd src/$(LINUX_DIR) && $(MAKE)
	cp src/$(LINUX_DIR)/arch/x86/boot/bzImage bzImage

coreboot.rom: bzImage initramfs.cpio.gz stamp/build-coreboot-toolchain
	cp configs/$(BOARD)_coreboot.config src/$(COREBOOT_DIR)/.config
	cd src/$(COREBOOT_DIR) && $(MAKE)
	cp src/$(COREBOOT_DIR)/build/coreboot.rom $(ROOT_DIR)

kernelmenuconfig: stamp/fetch-linux
	cp configs/$(BOARD)_kernel.config src/$(LINUX_DIR)/.config
	cd src/$(LINUX_DIR) && make menuconfig
	cp src/$(LINUX_DIR)/.config configs/$(BOARD)_kernel.config

corebootmenuconfig: stamp/fetch-coreboot
	cp configs/$(BOARD)_coreboot.config src/$(COREBOOT_DIR)/.config
	cd src/$(COREBOOT_DIR) && make menuconfig
	cp src/$(COREBOOT_DIR)/.config configs/$(BOARD)_coreboot.config

clean:
	-rm -rf bzImage initramfs.cpio.gz

distclean:
	$(MAKE) clean
	-rm -rf src dist stamp