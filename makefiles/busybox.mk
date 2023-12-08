BUSYBOX=build/busybox
BUSYBOX_DIR=busybox-$(BUSYBOX_VER)
BUSYBOX_TARBALL=$(BUSYBOX_DIR).tar.bz2
BUSYBOX_URL=https://busybox.net/downloads/$(BUSYBOX_TARBALL)

stamp/fetch-busybox:
	$(call fetch,BUSYBOX)
	touch $@

$(BUSYBOX): stamp/build-glibc stamp/build-linux-headers stamp/fetch-busybox
	cp config/busybox.config src/$(BUSYBOX_DIR)/.config
	cd src/$(BUSYBOX_DIR) && $(MAKE)
	cp src/$(BUSYBOX_DIR)/busybox build

.PHONY: busybox_menuconfig
busybox_menuconfig: stamp/fetch-busybox
	cp config/busybox.config src/$(BUSYBOX_DIR)/.config
	cd src/$(BUSYBOX_DIR) && make menuconfig
	cp src/$(BUSYBOX_DIR)/.config config/busybox.config
