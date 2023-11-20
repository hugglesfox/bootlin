BUSYBOX_DIR=busybox-$(BUSYBOX_VER)
BUSYBOX_TARBALL=$(BUSYBOX_DIR).tar.bz2
BUSYBOX_URL=https://busybox.net/downloads/$(BUSYBOX_TARBALL)

stamp/fetch-busybox:
	$(call fetch,BUSYBOX)
	touch $@

stamp/build-busybox: stamp/build-musl stamp/build-linux-headers stamp/fetch-busybox
	cp config/busybox.config src/$(BUSYBOX_DIR)/.config
	cd src/$(BUSYBOX_DIR) && $(MAKE)
	cd src/$(BUSYBOX_DIR) && $(MAKE) install
	touch $@

.PHONY: busyboxmenuconfig
busyboxmenuconfig: stamp/fetch-busybox
	cp config/busybox.config src/$(BUSYBOX_DIR)/.config
	cd src/$(BUSYBOX_DIR) && make menuconfig
	cp src/$(BUSYBOX_DIR)/.config config/busybox.config