KEXEC=build/kexec
KEXEC_TOOLS_DIR=kexec-tools-2.0.27
KEXEC_TOOLS_TARBALL=$(KEXEC_TOOLS_DIR).tar.gz
KEXEC_TOOLS_URL=https://git.kernel.org/pub/scm/utils/kernel/kexec/kexec-tools.git/snapshot/$(KEXEC_TOOLS_TARBALL)

stamp/fetch-kexec-tools:
	$(call fetch,KEXEC_TOOLS)
	touch $@

$(KEXEC): stamp/build-musl stamp/fetch-kexec-tools stamp/build-linux-headers
	cd src/$(KEXEC_TOOLS_DIR) && ./bootstrap
	cd src/$(KEXEC_TOOLS_DIR) && CFLAGS="$(CFLAGS) -static" ./configure
	cd src/$(KEXEC_TOOLS_DIR) && $(MAKE)
	cp src/$(KEXEC_TOOLS_DIR)/build/sbin/kexec build