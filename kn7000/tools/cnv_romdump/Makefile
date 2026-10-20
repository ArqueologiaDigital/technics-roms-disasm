# KN7LOAD.CNV (the floppy loader) and KN7APP.BIN (the ROM dumper, for the SD card). README.md.
PYTHON      ?= python3
XAPASM      := $(PYTHON) ../xapasm.py
FLOPPY_TOOLS ?= ../../../../kn7000_mame/tools/floppy-images
OUT         ?= build

all: $(OUT)/KN7LOAD.CNV $(OUT)/KN7APP.BIN $(OUT)/safe/KN7APP.BIN $(OUT)/ic19/KN7APP.BIN $(OUT)/wave/KN7APP.BIN \
     $(OUT)/survey/KN7APP.BIN $(OUT)/survey2/KN7APP.BIN $(OUT)/dspprobe/KN7APP.BIN $(OUT)/dspmem/KN7APP.BIN \
     $(OUT)/kn7load_floppy.img

$(OUT)/KN7LOAD.CNV: loader.s kn7cnv.inc font8x13.inc ../xapasm.py ../mn10300_asm.py
	@mkdir -p $(OUT)
	$(XAPASM) loader.s -o $@ -m $(OUT)/loader.map
	@test $$(stat -c%s $@) -le 7168 || { echo "loader.s: the image reaches LV_STR (0x502B9C00)"; rm -f -- $@; false; }

$(OUT)/romdump.bin: romdump.s romdump_dsp.s romdump.inc kn7cnv.inc ../xapasm.py ../mn10300_asm.py
	@mkdir -p $(OUT)
	$(XAPASM) romdump.s -o $@ -m $(OUT)/romdump.map
	@test $$(stat -c%s $@) -le 24576 || { echo "romdump.s: the image reaches BUF (0x502C0000)"; rm -f -- $@; false; }

$(OUT)/KN7APP.BIN: $(OUT)/romdump.bin mkapp.py
	$(PYTHON) -I mkapp.py $< $@

# the SAFE build (romdump.inc OPTS_SAFE): program, table and IC21 only; plain files in the root, through
# the firmware's own file routines only: no folder, no long-name pass, no raw SD sectors
$(OUT)/safe/KN7APP.BIN: $(OUT)/romdump.bin mkapp.py
	@mkdir -p $(OUT)/safe
	$(PYTHON) -I mkapp.py $< $@ --options 0x303E0 --name "KN7000 ROM DUMPER 1.0 SAFE"

# the IC19 build (OPTS_PICTURE): the picture flash window 0x57800000 alone, the same way as SAFE; a pass of
# its own, because that window's extent is not confirmed
$(OUT)/ic19/KN7APP.BIN: $(OUT)/romdump.bin mkapp.py
	@mkdir -p $(OUT)/ic19
	$(PYTHON) -I mkapp.py $< $@ --options 0x301FF --name "KN7000 ROM DUMPER 1.0 IC19"

# the WAVE build (OPTS_WAVE): the four wave ROMs alone (IC203, IC204, IC207, IC208, 16 MB each) through the
# tone generators' test latches, the way the firmware's own WAVE ROM test reads them; plain files in the
# root as in SAFE; each file's byte sum is checked against the firmware's expected sum ([SUM?] if not)
$(OUT)/wave/KN7APP.BIN: $(OUT)/romdump.bin mkapp.py
	@mkdir -p $(OUT)/wave
	$(PYTHON) -I mkapp.py $< $@ --options 0x3021F --name "KN7000 ROM DUMPER 1.0 WAVE"

# the SURVEY build (OPTS_SURVEY): not ROMs but six 8 MB windows, CS0 0x40000000-0x40FFFFFF and CS5
# 0x54000000-0x55FFFFFF, which cover every place the firmware looks for the rhythm ROM's header
# (SurveyTable in romdump.s); plain files in the root as in SAFE
$(OUT)/survey/KN7APP.BIN: $(OUT)/romdump.bin mkapp.py
	@mkdir -p $(OUT)/survey
	$(PYTHON) -I mkapp.py $< $@ --options 0x703C0 --name "KN7000 ROM DUMPER 1.0 SURVEY"

# the SURVEY2 build (OPTS_SURVEY2): Survey2Table's 14 windows in one run -- SurveyTable's six again (the same
# files, to compare with the first read), IC23 0x44000000 (2 MB), the kept work RAM 0x50180000-0x50297FFF, the
# library RAM 0x4C000000 (256 KB), 0x56800000 (2 MB, IC21 again?) and the four expansion slot windows (64 KB
# each); plain files in the root as in SAFE
$(OUT)/survey2/KN7APP.BIN: $(OUT)/romdump.bin mkapp.py
	@mkdir -p $(OUT)/survey2
	$(PYTHON) -I mkapp.py $< $@ --options 0xB0000 --name "KN7000 ROM DUMPER 1.0 SURVEY2"

# the DSP probe, phase 1 (OPTS_DSPPROBE): read-only; the main CPU's side of the effects DSP's host port, its IOP
# registers (less those whose read has a side effect) and a time series of its timers and SPORT DMA counts, through
# the firmware's own host-port routines (romdump_dsp.s); plain files in the root as in SAFE
$(OUT)/dspprobe/KN7APP.BIN: $(OUT)/romdump.bin mkapp.py
	@mkdir -p $(OUT)/dspprobe
	$(PYTHON) -I mkapp.py $< $@ --options 0x130000 --name "KN7000 DSP PROBE 1.0 PHASE 1"

# the DSP probe, phase 2 (OPTS_DSPMEM): reads the DSP's program and data memory back through external-port DMA
# channel 8 run in transmit direction; writes DMAC0, IIEP0, IMEP0, CEP0 and puts them back
$(OUT)/dspmem/KN7APP.BIN: $(OUT)/romdump.bin mkapp.py
	@mkdir -p $(OUT)/dspmem
	$(PYTHON) -I mkapp.py $< $@ --options 0x230000 --name "KN7000 DSP PROBE 1.0 PHASE 2"

# the loader alone on a blank disk the KN7000 formatted (the base every KN7000 image starts from)
$(OUT)/kn7load_floppy.img: $(OUT)/KN7LOAD.CNV mkfloppy.py
	$(PYTHON) -I mkfloppy.py $@ KN7LOADER $(FLOPPY_TOOLS) $<

font8x13.inc: gen_font.py
	$(PYTHON) -I gen_font.py /usr/share/fonts/X11/misc/8x13-ISO8859-1.pcf.gz $@

clean:
	rm -rf -- $(OUT)

.PHONY: all clean
