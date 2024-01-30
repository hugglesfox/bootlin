X220_BLOBS_DIR = blobs/thinkpad/x220

$(X220_BLOBS_DIR)/ifd.bin:
$(X220_BLOBS_DIR)/gbe.bin:

$(X220_BLOBS_DIR)/me.bin:
	cd $(X220_BLOBS_DIR) && wget https://download.lenovo.com/ibmdl/pub/pc/pccbbs/mobiles/83rf46ww.exe
	cd $(X220_BLOBS_DIR) && innoextract 83rf46ww.exe 
	cd $(X220_BLOBS_DIR) && python me7_update_parser.py -O me.bin app/ME7_5M_UPD_Production.bin 
	rm -rf $(X220_BLOBS_DIR)/app $(X220_BLOBS_DIR)/83rf46ww.exe


