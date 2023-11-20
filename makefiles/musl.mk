MUSL_DIR=musl-$(MUSL_VER)
MUSL_TARBALL=$(MUSL_DIR).tar.gz
MUSL_URL=https://git.musl-libc.org/cgit/musl/snapshot/$(MUSL_TARBALL)

stamp/fetch-musl:
	$(call fetch,MUSL)
	touch $@

stamp/build-musl: stamp/fetch-musl
	cd src/$(MUSL_DIR) && ./configure --prefix=$(SYSROOT)/usr
	cd src/$(MUSL_DIR) && $(MAKE)
	cd src/$(MUSL_DIR) && $(MAKE) install
	touch $@