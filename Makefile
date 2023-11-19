ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

CFLAGS=-march=x86-64 -O3
MAKEFLAGS=-j10

export CFLAGS
export MAKEFLAGS

LINUX_DIR=linux-6.6.1
LINUX_TARBALL=$(LINUX_DIR).tar.xz
LINUX_KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)

BUSYBOX_DIR=busybox-1.36.1
BUSYBOX_TARBALL=$(BUSYBOX_DIR).tar.bz2
BUSYBOX_URL=https://busybox.net/downloads/$(BUSYBOX_TARBALL)

MUSL_DIR=musl-1.2.4
MUSL_TARBALL=$(MUSL_DIR).tar.gz
MUSL_URL=https://git.musl-libc.org/cgit/musl/snapshot/$(MUSL_TARBALL)

.PHONY: all clean mrproper kernelmenuconfig busyboxmenuconfig

all: bzImage

stamp/fetch-musl:
	mkdir -p dist src stamp build
	cd dist && wget $(MUSL_URL)
	cd src && tar -xvf ../dist/$(MUSL_TARBALL)
	touch stamp/fetch-musl

stamp/fetch-kernel:
	mkdir -p dist src stamp build
	cd dist && wget $(LINUX_KERNEL_URL)
	cd src && tar -xvf ../dist/$(LINUX_TARBALL)
	touch stamp/fetch-kernel

stamp/fetch-busybox:
	mkdir -p dist src stamp build
	cd dist && wget $(BUSYBOX_URL)
	cd src && tar -xvf ../dist/$(BUSYBOX_TARBALL)
	touch stamp/fetch-busybox

build/sysroot: stamp/fetch-musl stamp/fetch-kernel
	cd src/$(MUSL_DIR) && ./configure --prefix=$(ROOT_DIR)/build/sysroot/usr
	cd src/$(MUSL_DIR) && $(MAKE)
	cd src/$(MUSL_DIR) && $(MAKE) install
	cd src/$(LINUX_DIR) && $(MAKE) headers_install INSTALL_HDR_PATH=$(ROOT_DIR)/build/sysroot/usr

build/image: build/sysroot stamp/fetch-busybox
	cp config/busybox.config src/$(BUSYBOX_DIR)/.config
	cd src/$(BUSYBOX_DIR) && $(MAKE)
	cd src/$(BUSYBOX_DIR) && $(MAKE) install

build/initramfs.cpio.gz: build/image
	mkdir -p build/image/sys build/image/dev build/image/proc
	cp init build/image
	cd build/image && find . | cpio -o -H newc | gzip > ../initramfs.cpio.gz

bzImage: build/initramfs.cpio.gz stamp/fetch-kernel
	mkdir -p out
	cp config/kernel.config src/$(LINUX_DIR)/.config
	cd src/$(LINUX_DIR) && $(MAKE)
	cp src/$(LINUX_DIR)/arch/x86/boot/bzImage bzImage

kernelmenuconfig: stamp/fetch-kernel
	cp config/kernel.config src/$(LINUX_DIR)/.config
	cd src/$(LINUX_DIR) && make menuconfig
	cp src/$(LINUX_DIR)/.config config/kernel.config

busyboxmenuconfig: stamp/fetch-busybox
	cp config/busybox.config src/$(BUSYBOX_DIR)/.config
	cd src/$(BUSYBOX_DIR) && make menuconfig
	cp src/$(BUSYBOX_DIR)/.config config/busybox.config

clean:
	-rm -rf bzImage build

mrproper:
	-rm -rf bzImage build src dist stamp