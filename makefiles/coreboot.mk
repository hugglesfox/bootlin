COREBOOT_DIR=coreboot-$(COREBOOT_VER)
COREBOOT_TARBALL=$(COREBOOT_DIR).tar.xz
COREBOOT_URL=https://coreboot.org/releases/$(COREBOOT_TARBALL)

COREBOOT_BLOBS_DIR=$(COREBOOT_DIR)/3rdparty
COREBOOT_BLOBS_TARBALL=coreboot-blobs-$(COREBOOT_VER).tar.xz
COREBOOT_BLOBS_URL=https://coreboot.org/releases/$(COREBOOT_BLOBS_TARBALL)

stamp/fetch-coreboot:
	$(call fetch,COREBOOT)
	touch $@

stamp/fetch-coreboot-blobs: stamp/fetch-coreboot
	$(call fetch,COREBOOT_BLOBS)
	touch $@

stamp/setup-coreboot-toolchain: stamp/fetch-coreboot
	cd src/$(COREBOOT_DIR) && CFLAGS="" $(MAKE) crossgcc-i386 CPUS=8
	touch $@

coreboot.rom: build/bzImage $(BLOBS) stamp/setup-coreboot-toolchain stamp/fetch-coreboot-blobs
	cp config/$(BOARD)_coreboot.config src/$(COREBOOT_DIR)/.config
	cd src/$(COREBOOT_DIR) && $(MAKE)
	cp src/$(COREBOOT_DIR)/build/coreboot.rom $(ROOT_DIR)

.PHONY: coreboot_menuconfig
coreboot_menuconfig: stamp/fetch-coreboot
	cp config/$(BOARD)_coreboot.config src/$(COREBOOT_DIR)/.config
	cd src/$(COREBOOT_DIR) && $(MAKE) menuconfig
	cp src/$(COREBOOT_DIR)/.config config/$(BOARD)_coreboot.config

.PHONY: coreboot_distclean
coreboot_distclean: stamp/fetch-coreboot
	cd src/$(COREBOOT_DIR) && $(MAKE) distclean
	rm -f stamp/fetch-coreboot-blobs