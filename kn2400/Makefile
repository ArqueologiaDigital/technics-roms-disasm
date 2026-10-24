# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Rebuild the Technics SX-KN2400 / SX-KN2600 program flash image (Panasonic
# MN10300, MILK framework, linked at 0x48400000) from disassembly source and
# verify that the result is 100% byte-identical to the image the manufacturer's
# v1.1 update installs.
#
# The assembler and the helper scripts are the KN7000 tree's (../kn7000/tools);
# nothing is copied.

PYTHON   ?= python3
TOOLS    := ../kn7000/tools
ASM      := $(PYTHON) $(TOOLS)/kn7asm.py

# The Technics/Panasonic customer-service mirror beside this tree (private, not in
# git). kn24-11.zip holds the two self-extracting floppy images of update v1.1;
# kn26-11.zip, the KN2600 package, holds the same image uncompressed.
# Override on the command line if it lives elsewhere: make CA_MIRROR=/path/files
CA_MIRROR ?= ../../ca-software-mirror/files
UPDATE    := $(CA_MIRROR)/7000/files/kn24-11.zip
UPDATE26  := $(CA_MIRROR)/7000/files/kn26-11.zip

# MAME's unidasm; only `make program-src` needs it.
UNIDASM  ?= ../../tools/unidasm

ROM      := kn2400_program.rom
# SHA-1 of the 3,761,619-byte image (LKG1.SLD + LKG2.SLD, decompressed, joined).
ROM_SHA1 := 39163ea892baf8ad11419c29fe58cc536bef9ca7
# File-offset ranges that hold code (LO:HI, or LO:HI:CPU when the range is linked
# for another address than its flash one): the boot vectors; the code linked for
# flash, from the MILK kernel to 0x3285be; and the code linked for work RAM at
# 0x50120000, which runs from 0x3285be to the 24-byte trailer at the end of the
# image (README.md, "Layout"). The data comes first in this image.
CODE     := --code 0x0:0x10 --code 0x1e4000:0x3285be --code 0x3285be:0x3965bb:0x50120000

.PHONY: all baserom build verify verify-kn2600 symbols program-src clean distclean
.DELETE_ON_ERROR:

all: verify

# ---- reference image: regenerated from the installers, never committed -------
# sfx_extract.py reads the ZIP archive appended to each self-extracting .exe (it
# never runs it); sld_decompress.py undoes the LZSS; smck_check.py checks the
# image against the 15 block sums and the total the update floppy carries.
baserom: baserom/$(ROM)

baserom/kn24_11a.exe baserom/kn24_11b.exe: | baserom/.dir
	$(PYTHON) $(TOOLS)/sfx_extract.py $(UPDATE) $(notdir $@) $@
baserom/LKG1.SLD baserom/SMCKPR1.INF: baserom/kn24_11a.exe
	$(PYTHON) $(TOOLS)/sfx_extract.py $< $(notdir $@) $@
baserom/LKG2.SLD: baserom/kn24_11b.exe
	$(PYTHON) $(TOOLS)/sfx_extract.py $< $(notdir $@) $@
baserom/%.bin: baserom/%.SLD
	$(PYTHON) $(TOOLS)/sld_decompress.py $< $@
baserom/$(ROM): baserom/LKG1.bin baserom/LKG2.bin baserom/SMCKPR1.INF
	cat baserom/LKG1.bin baserom/LKG2.bin > $@
	$(PYTHON) $(TOOLS)/smck_check.py $@ baserom/SMCKPR1.INF --expect match
	@[ "$$(sha1sum < $@ | cut -d' ' -f1)" = "$(ROM_SHA1)" ] \
	    || { echo "FAIL  $@: SHA-1 is not $(ROM_SHA1)"; exit 1; }
	@echo "OK    $@ has the recorded SHA-1 $(ROM_SHA1)"
baserom/.dir:
	@mkdir -p baserom && touch $@

# ---- build ---------------------------------------------------------------------
build/$(ROM): src/program.s src/symbols.inc src/labels.inc $(TOOLS)/kn7asm.py $(TOOLS)/mn10300_asm.py baserom/$(ROM)
	@mkdir -p build
	$(ASM) src/program.s -I . -o $@

build: build/$(ROM)

verify: build/$(ROM)
	@if cmp -s build/$(ROM) baserom/$(ROM); then \
	    echo "OK    $(ROM) is 100% byte-identical to the original"; \
	 else echo "FAIL  $(ROM) differs from the original:"; cmp build/$(ROM) baserom/$(ROM); exit 1; fi

# The KN2600 v1.1 package ships the same image as one uncompressed file.
verify-kn2600: baserom/$(ROM) | baserom/.dir
	$(PYTHON) $(TOOLS)/sfx_extract.py $(UPDATE26) KN24PRG.DAT baserom/KN24PRG.DAT
	@cmp baserom/KN24PRG.DAT baserom/$(ROM) \
	    && echo "OK    kn26-11.zip KN24PRG.DAT == $(ROM): the KN2600 runs the KN2400 image"

# ---- symbols from the firmware's own MILK reflection tables --------------------
# Only tables whose procedures land in the code ranges count: with the whole image
# as "code", gen_symbols.py also accepts event-name string tables (MT_GetPadRun
# would name the text "EV_DISPPADRUN") and a menu table pointing into data.
symbols kn2400.sym src/symbols.inc: $(TOOLS)/gen_symbols.py baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_symbols.py baserom/$(ROM) --program-base 0x48400000 \
	    --code-range 0x1e4000:0x3285be --no-manual \
	    --title "KN2400/KN2600 program-image symbols recovered from the MILK toolkit" \
	    --inc-title "KN2400/KN2600 symbols" --sym kn2400.sym --inc src/symbols.inc

# ---- regenerate src/program.s (needs unidasm) ------------------------------------
program-src: $(TOOLS)/gen_image_s.py kn2400.sym kn2400_manual.sym src/symbols.inc baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_image_s.py --rom baserom/$(ROM) --base 0x48400000 $(CODE) \
	    --sym kn2400.sym kn2400_manual.sym --inc src/symbols.inc --labels-inc src/labels.inc \
	    --out src/program.s \
	    --unidasm $(UNIDASM) --stats notes/conversion-stats.txt \
	    --title 'Technics SX-KN2400 / SX-KN2600 program flash image (update v1.1) - byte-exact.' \
	    --title 'Panasonic MN10300, linked at 0x48400000. See README.md.'

clean:
	rm -rf build

distclean: clean
	rm -rf baserom
