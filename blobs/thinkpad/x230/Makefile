X230_BLOBS_DIR = blobs/thinkpad/x230

$(X230_BLOBS_DIR)/ifd.bin:

$(X230_BLOBS_DIR)/gbe.bin: stamp/fetch-coreboot
	cd src/$(COREBOOT_DIR)/util/bincfg && $(MAKE) gen-gbe-82579LM WERROR=""
	mv src/$(COREBOOT_DIR)/util/bincfg/flashregion_3_gbe.bin $(X230_BLOBS_DIR)/gbe.bin

$(X230_BLOBS_DIR)/me.bin:
	cd $(X230_BLOBS_DIR) && wget https://download.lenovo.com/pccbbs/mobiles/g1rg24ww.exe
	cd $(X230_BLOBS_DIR) && innoextract g1rg24ww.exe 
	cd $(X230_BLOBS_DIR) && python me_cleaner.py -t -r -O me.bin app/ME8_5M_Production.bin 
	rm -rf $(X230_BLOBS_DIR)/app $(X230_BLOBS_DIR)/g1rg24ww.exe

