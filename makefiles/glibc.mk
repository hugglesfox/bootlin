GLIBC_DIR=glibc-$(GLIBC_VER)
GLIBC_TARBALL=$(GLIBC_DIR).tar.gz
GLIBC_URL=https://ftp.gnu.org/gnu/glibc/$(GLIBC_TARBALL)

stamp/fetch-glibc:
	$(call fetch,GLIBC)
	touch $@

stamp/build-glibc: stamp/fetch-glibc
	cd src/$(GLIBC_DIR) && mkdir -p build
	cd src/$(GLIBC_DIR)/build && ../configure --prefix=$(SYSROOT)/usr
	cd src/$(GLIBC_DIR)/build && $(MAKE)
	cd src/$(GLIBC_DIR)/build && $(MAKE) install
	touch $@
