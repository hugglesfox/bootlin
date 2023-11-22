COREBOOT_DIR=coreboot-$(COREBOOT_VER)
COREBOOT_TARBALL=$(COREBOOT_DIR).tar.xz
COREBOOT_URL=https://coreboot.org/releases/$(COREBOOT_TARBALL)

stamp/fetch-coreboot:
	$(call fetch,COREBOOT)
	touch $@

stamp/setup-coreboot-toolchain: stamp/fetch-coreboot
	cd src/$(COREBOOT_DIR) && CFLAGS="" $(MAKE) crossgcc-i386 CPUS=8
	touch $@

coreboot.rom: bzImage $(BLOBS) stamp/setup-coreboot-toolchain
	cp config/$(BOARD)_coreboot.config src/$(COREBOOT_DIR)/.config
	cd src/$(COREBOOT_DIR) && $(MAKE)
	cp src/$(COREBOOT_DIR)/build/coreboot.rom $(ROOT_DIR)

corebootmenuconfig: stamp/fetch-coreboot
	cp config/$(BOARD)_coreboot.config src/$(COREBOOT_DIR)/.config
	cd src/$(COREBOOT_DIR) && $(MAKE) menuconfig
	cp src/$(COREBOOT_DIR)/.config config/$(BOARD)_coreboot.config