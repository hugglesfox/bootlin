ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

CFLAGS=-march=x86-64 -Os
MAKEFLAGS=-j10

export CFLAGS
export MAKEFLAGS

LINUX_DIR=linux-6.6.1
LINUX_TARBALL=$(LINUX_DIR).tar.xz
LINUX_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)

UROOT_DIR=u-root-0.11.0
UROOT_TARBALL=$(UROOT_DIR).tar.gz
UROOT_URL=https://github.com/u-root/u-root/archive/refs/tags/v0.11.0.tar.gz

define fetch
	mkdir -p dist src stamp build
	cd dist && wget -O $($(1)_TARBALL) $($(1)_URL)
	cd src && tar -xvf ../dist/$($(1)_TARBALL)
endef

.PHONY: all clean distclean kernelmenuconfig

all: bzImage

stamp/fetch-linux:
	$(call fetch,LINUX)
	touch $@

stamp/fetch-uroot:
	$(call fetch,UROOT)
	touch $@

stamp/build-uroot: stamp/fetch-uroot
	cd src/$(UROOT_DIR) && go build

initramfs.cpio.gz: stamp/build-uroot
	cd src/$(UROOT_DIR) && ./u-root -o $(ROOT_DIR)/initramfs.cpio core boot
	gzip -f initramfs.cpio

bzImage: initramfs.cpio.gz stamp/fetch-linux
	cp kernel.config src/$(LINUX_DIR)/.config
	cd src/$(LINUX_DIR) && $(MAKE)
	cp src/$(LINUX_DIR)/arch/x86/boot/bzImage bzImage

kernelmenuconfig: stamp/fetch-linux
	cp kernel.config src/$(LINUX_DIR)/.config
	cd src/$(LINUX_DIR) && make menuconfig
	cp src/$(LINUX_DIR)/.config kernel.config

clean:
	-rm -rf bzImage initramfs.cpio.gz stamp/build-*

distclean:
	$(MAKE) clean
	-rm -rf src dist stamp