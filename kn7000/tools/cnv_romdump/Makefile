# KN7LOAD.CNV (the floppy loader) and KN7APP.BIN (the ROM dumper, for the SD card). README.md.
PYTHON      ?= python3
XAPASM      := $(PYTHON) ../xapasm.py
FLOPPY_TOOLS ?= ../../../kn7000_mame/tools/floppy-images
OUT         ?= build

all: $(OUT)/KN7LOAD.CNV $(OUT)/KN7APP.BIN $(OUT)/kn7load_floppy.img

$(OUT)/KN7LOAD.CNV: loader.s kn7cnv.inc font8x13.inc ../xapasm.py ../mn10300_asm.py
	@mkdir -p $(OUT)
	$(XAPASM) loader.s -o $@ -m $(OUT)/loader.map

$(OUT)/romdump.bin: romdump.s romdump.inc kn7cnv.inc ../xapasm.py ../mn10300_asm.py
	@mkdir -p $(OUT)
	$(XAPASM) romdump.s -o $@ -m $(OUT)/romdump.map

$(OUT)/KN7APP.BIN: $(OUT)/romdump.bin mkapp.py
	$(PYTHON) -I mkapp.py $< $@

# the loader alone on a blank disk the KN7000 formatted (the base every KN7000 image starts from)
$(OUT)/kn7load_floppy.img: $(OUT)/KN7LOAD.CNV mkfloppy.py
	$(PYTHON) -I mkfloppy.py $@ KN7LOADER $(FLOPPY_TOOLS) $<

font8x13.inc: gen_font.py
	$(PYTHON) -I gen_font.py /usr/share/fonts/X11/misc/8x13-ISO8859-1.pcf.gz $@

clean:
	rm -rf -- $(OUT)

.PHONY: all clean
