define fetch
	mkdir -p $(SYSROOT)/usr/lib
	touch $(SYSROOT)/usr/lib/musl-gcc.specs

	mkdir -p dist src stamp
	cd dist && wget -O $($(1)_TARBALL) $($(1)_URL)
	cd src && tar -xvf ../dist/$($(1)_TARBALL)
endef
