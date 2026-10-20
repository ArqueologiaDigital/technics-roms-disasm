# DSPTONE (README.md): our own program on the KN7000's effects DSP, as a KN7LOAD.CNV application for the
# program menu's card (folder DSPTONE\).
#   make            build/KN7APP.BIN, after dsp_prog.py --check (every SHARC instruction disassembles as meant,
#                   MAME's unidasm) and guard.py (memory map, IC23/pools/loader/DSP-port references, frames)
#   make card-dir   build/card/DSPTONE/: KN7APP.BIN, MANIFEST.TXT, ICON.BMP (what the menu's card gets)
PYTHON  ?= python3
TOOLS   := ..
LOADER  := ../cnv_romdump
MENU    := ../kn7menu
XAPASM  := $(PYTHON) $(TOOLS)/xapasm.py
UNIDASM ?= $(HOME)/compartilhado/mame-sony-video/unidasm
OUT     ?= build
INC     := -I . -I $(OUT) -I $(LOADER)

all: $(OUT)/KN7APP.BIN

$(OUT)/dsp_equ.inc $(OUT)/dsp_data.inc: dsp_prog.py sharc_enc.py
	@mkdir -p $(OUT)
	$(PYTHON) -I dsp_prog.py $(OUT) --check $(UNIDASM) --listing $(OUT)/dsp.lst --wav $(OUT)/chirp.wav

$(OUT)/dsptone.bin: dsptone.s dsptone.inc $(OUT)/dsp_equ.inc $(OUT)/dsp_data.inc $(LOADER)/kn7cnv.inc \
                    $(LOADER)/font8x13.inc $(TOOLS)/xapasm.py $(TOOLS)/mn10300_asm.py
	$(XAPASM) dsptone.s $(INC) -o $@ -m $(OUT)/dsptone.map

$(OUT)/guard.txt: $(OUT)/dsptone.bin guard.py
	$(PYTHON) -I guard.py $(TOOLS) $(LOADER) $(OUT) > $@ || { cat $@; rm -f -- $@; false; }
	@tail -1 $@

$(OUT)/KN7APP.BIN: $(OUT)/dsptone.bin $(OUT)/guard.txt $(LOADER)/mkapp.py
	$(PYTHON) -I $(LOADER)/mkapp.py $(OUT)/dsptone.bin $@
	@sha1sum $@

card-dir: $(OUT)/KN7APP.BIN $(MENU)/gen_icons.py $(MENU)/png2icon.py
	@mkdir -p $(OUT)/card/DSPTONE
	cp $(OUT)/KN7APP.BIN $(OUT)/card/DSPTONE/KN7APP.BIN
	printf '# DSPTONE: the KN7000 program menu shows this name and icon (kn7menu/README.md)\r\nNAME=DSP tone: our own effects-DSP program\r\nICON=ICON.BMP\r\n' > $(OUT)/card/DSPTONE/MANIFEST.TXT
	$(PYTHON) -I $(MENU)/gen_icons.py --png dsptone $(OUT)/dsptone_icon.png
	$(PYTHON) -I $(MENU)/png2icon.py $(OUT)/dsptone_icon.png $(OUT)/card/DSPTONE/ICON.BMP

clean:
	test -n "$(OUT)" && rm -rf -- "$(OUT)"

.PHONY: all card-dir clean
