define fetch
	mkdir -p dist src stamp
	cd dist && wget -O $($(1)_TARBALL) $($(1)_URL)
	cd src && tar -xvf ../dist/$($(1)_TARBALL)
endef


stamp/build-tools: stamp/build-busybox stamp/build-kexec-tools stamp/build-cryptsetup stamp/build-flashrom