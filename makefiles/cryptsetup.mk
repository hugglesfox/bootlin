CRYPTSETUP=build/cryptsetup
CRYPTSETUP_DIR=cryptsetup-$(CRYPTSETUP_VER)
CRYPTSETUP_TARBALL=$(CRYPTSETUP_DIR).tar.xz
CRYPTSETUP_URL=https://www.kernel.org/pub/linux/utils/cryptsetup/v2.6/$(CRYPTSETUP_TARBALL)

POPT_DIR=popt-$(POPT_VER)
POPT_TARBALL=$(POPT_DIR).tar.gz
POPT_URL=http://ftp.rpm.org/popt/releases/popt-1.x/$(POPT_TARBALL)

LVM_DIR=LVM2.$(LVM_VER)
LVM_TARBALL=$(LVM_DIR).tgz
LVM_URL=https://sourceware.org/pub/lvm2/$(LVM_TARBALL)

AIO_DIR=libaio-libaio-$(AIO_VER)
AIO_TARBALL=$(AIO_DIR).tar.gz
AIO_URL=https://pagure.io/libaio/archive/libaio-$(AIO_VER)/$(AIO_TARBALL)

JSON_C_DIR=json-c-$(JSON_C_VER)
JSON_C_TARBALL=$(JSON_C_DIR).tar.gz
JSON_C_URL=https://s3.amazonaws.com/json-c_releases/releases/$(JSON_C_TARBALL)

ARGON2_DIR=phc-winner-argon2-$(ARGON2_VER)
ARGON2_TARBALL=$(ARGON2_DIR).tar.gz
ARGON2_URL=https://github.com/P-H-C/phc-winner-argon2/archive/refs/tags/$(ARGON2_VER).tar.gz

stamp/fetch-cryptsetup:
	$(call fetch,CRYPTSETUP)
	touch $@

stamp/fetch-popt:
	$(call fetch,POPT)
	touch $@

stamp/fetch-lvm:
	$(call fetch,LVM)
	touch $@

stamp/fetch-aio:
	$(call fetch,AIO)
	touch $@

stamp/fetch-json-c:
	$(call fetch,JSON_C)
	touch $@

stamp/fetch-argon2:
	$(call fetch,ARGON2)
	touch $@

stamp/build-aio: stamp/fetch-aio stamp/build-musl stamp/build-linux-headers
	cd src/$(AIO_DIR) && $(MAKE)
	cd src/$(AIO_DIR) && $(MAKE) DESTDIR=$(SYSROOT) install
	touch $@

stamp/build-json-c: stamp/build-musl stamp/fetch-json-c
	cd src/$(JSON_C_DIR) && cmake . -DCMAKE_INSTALL_PREFIX=$(SYSROOT)/usr -DCMAKE_BUILD_TYPE=release
	cd src/$(JSON_C_DIR) && $(MAKE)
	cd src/$(JSON_C_DIR) && $(MAKE) install
	touch $@

stamp/build-argon2: stamp/fetch-argon2 stamp/build-musl
	cd src/$(ARGON2_DIR) && $(MAKE) DESTDIR=$(SYSROOT) LIBRARY_REL=lib OPTTARGET=$(TARGET_MARCH) install
	touch $@

stamp/build-lvm: stamp/fetch-lvm stamp/build-musl stamp/build-util-linux stamp/build-aio 
	cd src/$(LVM_DIR) && \
		ac_cv_lib_c_canonicalize_file_name=no \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
			--host=x86_64-pc-linux-musl \
			--prefix=$(SYSROOT)/usr \
			--enable-pkgconfig \
			--enable-static_link
	cd src/$(LVM_DIR) && $(MAKE) device-mapper
	cd src/$(LVM_DIR) && $(MAKE) install_device-mapper
	touch $@

stamp/build-popt: stamp/fetch-popt stamp/build-musl
	cd src/$(POPT_DIR) && ./configure \
		--host=x86_64-pc-linux-musl \
		--prefix=$(SYSROOT)/usr
	cd src/$(POPT_DIR) && $(MAKE)
	cd src/$(POPT_DIR) && $(MAKE) install
	touch $@

$(CRYPTSETUP): stamp/fetch-cryptsetup stamp/build-argon2 stamp/build-popt stamp/build-lvm stamp/build-util-linux stamp/build-json-c
	cd src/$(CRYPTSETUP_DIR) && \
		ac_cv_func_dlvsym=no \
		./configure \
		--host=x86_64-pc-linux-musl \
		--enable-static-cryptsetup \
		--disable-asciidoc \
		--disable-ssh-token \
		--disable-udev \
		--enable-libargon2 \
		--with-crypto-backend=kernel
	
	cd src/$(CRYPTSETUP_DIR) && sed -i 's/-ludev//' Makefile
	cd src/$(CRYPTSETUP_DIR) && $(MAKE)
	cp src/$(CRYPTSETUP_DIR)/cryptsetup.static build/cryptsetup
