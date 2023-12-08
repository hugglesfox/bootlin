LINUX_DIR=linux-$(LINUX_VER)
LINUX_TARBALL=$(LINUX_DIR).tar.xz
LINUX_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)

UTIL_LINUX_DIR=util-linux-$(UTIL_LINUX_VER)
UTIL_LINUX_TARBALL=$(UTIL_LINUX_DIR).tar.gz
UTIL_LINUX_URL=https://cdn.kernel.org/pub/linux/utils/util-linux/v$(UTIL_LINUX_VER)/$(UTIL_LINUX_TARBALL)

stamp/fetch-linux:
	$(call fetch,LINUX)
	touch $@

stamp/fetch-util-linux:
	$(call fetch,UTIL_LINUX)
	touch $@

stamp/build-linux-headers: stamp/fetch-linux
	cd src/$(LINUX_DIR) && $(MAKE) headers_install INSTALL_HDR_PATH=$(ROOT_DIR)/build/sysroot/usr
	touch $@

stamp/build-util-linux: stamp/fetch-util-linux stamp/build-musl stamp/build-linux-headers
	cd src/$(UTIL_LINUX_DIR) && ./configure \
		--prefix=$(SYSROOT)/usr \
		--disable-all-programs \
		--enable-libuuid \
		--enable-libblkid \
		--without-python
	cd src/$(UTIL_LINUX_DIR) && $(MAKE)
	cd src/$(UTIL_LINUX_DIR) && $(MAKE) install
	touch $@

build/bzImage: stamp/fetch-linux $(TOOLS)
	cp config/$(BOARD)_kernel.config src/$(LINUX_DIR)/.config
	cd src/$(LINUX_DIR) && $(MAKE)
	cp src/$(LINUX_DIR)/arch/x86/boot/bzImage build/bzImage

.PHONY: kernel_menuconfig
kernel_menuconfig: stamp/fetch-linux
	cp config/$(BOARD)_kernel.config src/$(LINUX_DIR)/.config
	cd src/$(LINUX_DIR) && make menuconfig
	cp src/$(LINUX_DIR)/.config config/$(BOARD)_kernel.config