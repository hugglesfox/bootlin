NVRAMTOOL=build/nvramtool

$(NVRAMTOOL): stamp/fetch-coreboot stamp/build-musl
	sed -i "s:^CFLAGS.*:CFLAGS=$(CFLAGS) -static -I. -DCMOS_HAL=1:" src/$(COREBOOT_DIR)/util/nvramtool/Makefile
	cd src/$(COREBOOT_DIR)/util/nvramtool && $(MAKE)
	cp src/$(COREBOOT_DIR)/util/nvramtool/nvramtool $(NVRAMTOOL)
