ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BOARD := qemu

CFLAGS := -march=x86-64 -Os
MAKEFLAGS := -j10

export CFLAGS
export MAKEFLAGS

LINUX_DIR=linux-6.6.1
LINUX_TARBALL=$(LINUX_DIR).tar.xz
LINUX_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)

BUSYBOX_DIR=busybox-1.36.1
BUSYBOX_TARBALL=$(BUSYBOX_DIR).tar.bz2
BUSYBOX_URL=https://busybox.net/downloads/$(BUSYBOX_TARBALL)

MUSL_DIR=musl-1.2.4
MUSL_TARBALL=$(MUSL_DIR).tar.gz
MUSL_URL=https://git.musl-libc.org/cgit/musl/snapshot/$(MUSL_TARBALL)

KEXEC_TOOLS_DIR=kexec-tools-2.0.27
KEXEC_TOOLS_TARBALL=$(KEXEC_TOOLS_DIR).tar.gz
KEXEC_TOOLS_URL=https://git.kernel.org/pub/scm/utils/kernel/kexec/kexec-tools.git/snapshot/$(KEXEC_TOOLS_TARBALL)

COREBOOT_DIR=coreboot-4.21
COREBOOT_TARBALL=$(COREBOOT_DIR).tar.xz
COREBOOT_URL=https://coreboot.org/releases/$(COREBOOT_TARBALL)

define fetch
	mkdir -p dist src stamp
	cd dist && wget -O $($(1)_TARBALL) $($(1)_URL)
	cd src && tar -xvf ../dist/$($(1)_TARBALL)
endef


.PHONY: all clean mrproper kernelmenuconfig busyboxmenuconfig

all: coreboot.rom

stamp/fetch-musl:
	$(call fetch,MUSL)
	touch $@

stamp/fetch-linux:
	$(call fetch,LINUX)
	touch $@

stamp/fetch-busybox:
	$(call fetch,BUSYBOX)
	touch $@

stamp/fetch-kexec-tools:
	$(call fetch,KEXEC_TOOLS)
	touch $@

stamp/fetch-coreboot:
	$(call fetch,COREBOOT)
	touch $@

stamp/build-coreboot-toolchain: stamp/fetch-coreboot
	cd src/$(COREBOOT_DIR) && $(MAKE) crossgcc-i386 CPUS=8
	touch $@

stamp/build-linux-headers: stamp/fetch-linux
	cd src/$(LINUX_DIR) && $(MAKE) headers_install INSTALL_HDR_PATH=$(ROOT_DIR)/build/sysroot/usr
	touch $@

stamp/build-musl: stamp/fetch-musl
	cd src/$(MUSL_DIR) && ./configure --prefix=$(ROOT_DIR)/build/sysroot/usr
	cd src/$(MUSL_DIR) && $(MAKE)
	cd src/$(MUSL_DIR) && $(MAKE) install

stamp/build-kexec-tools: stamp/fetch-kexec-tools
	cd src/$(KEXEC_TOOLS_DIR) && ./bootstrap
	cd src/$(KEXEC_TOOLS_DIR) && CFLAGS="$(CFLAGS) -static" ./configure --prefix=$(ROOT_DIR)/build
	cd src/$(KEXEC_TOOLS_DIR) && $(MAKE)
	cd src/$(KEXEC_TOOLS_DIR) && $(MAKE) install
	rm -rf build/share

stamp/build-busybox: stamp/build-musl stamp/build-linux-headers stamp/fetch-busybox
	cp config/busybox.config src/$(BUSYBOX_DIR)/.config
	cd src/$(BUSYBOX_DIR) && $(MAKE)
	cd src/$(BUSYBOX_DIR) && $(MAKE) install

bzImage: stamp/build-busybox stamp/build-kexec-tools stamp/fetch-linux
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

busyboxmenuconfig: stamp/fetch-busybox
	cp config/busybox.config src/$(BUSYBOX_DIR)/.config
	cd src/$(BUSYBOX_DIR) && make menuconfig
	cp src/$(BUSYBOX_DIR)/.config config/busybox.config

clean:
	-rm -rf build bzImage initramfs.cpio.gz

distclean:
	-rm -rf bzImage build src dist stamp