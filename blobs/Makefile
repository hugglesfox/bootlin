include blobs/thinkpad/x220/Makefile
include blobs/thinkpad/x230/Makefile

BLOBS =

ifeq ($(BOARD), thinkpad/x220)
	BLOBS += $(X220_BLOBS_DIR)/ifd.bin $(X220_BLOBS_DIR)/me.bin $(X220_BLOBS_DIR)/gbe.bin
else ifeq ($(BOARD), thinkpad/x230)
	BLOBS += $(X230_BLOBS_DIR)/ifd.bin $(X230_BLOBS_DIR)/me.bin $(X230_BLOBS_DIR)/gbe.bin
endif