FLASHROM=build/flashrom
FLASHROM_DIR=flashrom-v$(FLASHROM_VER)
FLASHROM_TARBALL=$(FLASHROM_DIR).tar.bz2
FLASHROM_URL=https://download.flashrom.org/releases/$(FLASHROM_TARBALL)

PCIUTILS_DIR=pciutils-$(PCIUTILS_VER)
PCIUTILS_TARBALL=$(PCIUTILS_DIR).tar.gz
PCIUTILS_URL=https://mirrors.edge.kernel.org/pub/software/utils/pciutils/$(PCIUTILS_TARBALL)

stamp/fetch-flashrom:
	$(call fetch,FLASHROM)
	touch $@

stamp/fetch-pciutils:
	$(call fetch,PCIUTILS)
	touch $@

stamp/build-pciutils: stamp/fetch-pciutils stamp/build-glibc stamp/build-linux-headers
	cd src/$(PCIUTILS_DIR) && $(MAKE) CFLAGS="$(CFLAGS)" DNS=no ZLIB=no HWDB=no LIBKMOD=no PREFIX=$(SYSROOT)/usr
	cd src/$(PCIUTILS_DIR) && $(MAKE) PREFIX=$(SYSROOT)/usr install-lib
	touch $@

$(FLASHROM): stamp/fetch-flashrom stamp/build-pciutils
	cd src/$(FLASHROM_DIR) && PKG_CONFIG_LIBDIR= PKG_CONFIG_PATH=$(SYSROOT)/usr/lib/pkgconfig $(MAKE) CONFIG_NOTHING=yes CONFIG_INTERNAL=yes CONFIG_INTERNAL_X86=yes CONFIG_STATIC=yes
	cp src/$(FLASHROM_DIR)/flashrom build
