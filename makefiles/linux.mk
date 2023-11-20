LINUX_DIR=linux-$(LINUX_VER)
LINUX_TARBALL=$(LINUX_DIR).tar.xz
LINUX_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)

stamp/fetch-linux:
	$(call fetch,LINUX)
	touch $@

stamp/build-linux-headers: stamp/fetch-linux
	cd src/$(LINUX_DIR) && $(MAKE) headers_install INSTALL_HDR_PATH=$(ROOT_DIR)/build/sysroot/usr
	touch $@

bzImage: stamp/build-busybox stamp/build-kexec-tools stamp/fetch-linux
	cp config/$(BOARD)_kernel.config src/$(LINUX_DIR)/.config
	cd src/$(LINUX_DIR) && $(MAKE)
	cp src/$(LINUX_DIR)/arch/x86/boot/bzImage bzImage

.PHONY: kernelmenuconfig
kernelmenuconfig: stamp/fetch-linux
	cp config/$(BOARD)_kernel.config src/$(LINUX_DIR)/.config
	cd src/$(LINUX_DIR) && make menuconfig
	cp src/$(LINUX_DIR)/.config config/$(BOARD)_kernel.config