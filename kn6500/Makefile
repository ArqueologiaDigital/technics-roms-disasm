# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Rebuild the Technics SX-KN6500 program flash image (Panasonic MN10300, MILK
# framework, linked at 0x4C000000) from disassembly source and verify that the
# result is 100% byte-identical to the image the manufacturer's v1.3 update
# installs.
#
# The assembler and the helper scripts are the KN7000 tree's (../kn7000/tools);
# nothing is copied.

PYTHON   ?= python3
TOOLS    := ../kn7000/tools
ASM      := $(PYTHON) $(TOOLS)/kn7asm.py

# The Technics/Panasonic customer-service mirror beside this tree (private, not in
# git). kn65-13.zip holds the two self-extracting floppy images of update v1.3.
# Override on the command line if it lives elsewhere: make CA_MIRROR=/path/files
CA_MIRROR ?= ../../ca-software-mirror/files
UPDATE    := $(CA_MIRROR)/6000/files/kn65-13.zip
EXE_A     := kn65_v1-3a.exe
EXE_B     := kn65_v1-3b.exe
SLD_A     := IKV1
SLD_B     := IKV2
INF       := SMCKPV1.INF

# MAME's unidasm; only `make program-src` needs it.
UNIDASM  ?= ../../tools/unidasm

MODEL    := kn6500
ROM      := $(MODEL)_program.rom
BASE     := 0x4c000000
# SHA-1 of the 3,675,793-byte image (IKV1.SLD + IKV2.SLD, decompressed, joined).
ROM_SHA1 := a507de3977def5d4148c4d3dbc16e3f6ff9f01c8
# File-offset ranges that hold code (README.md, "Layout"): the boot code and
# application from offset 0, and the MILK kernel at the top of the image.
CODE     := --code 0x0:0x176839 --code 0x37e44c:0x381447
SYMRANGE := --code-range 0x0:0x176839 --code-range 0x37e44c:0x381447
TITLE    := 'Technics SX-KN6500 program flash image (update v1.3) - byte-exact.'

.PHONY: all baserom build verify symbols program-src clean distclean
.DELETE_ON_ERROR:

all: verify

# ---- reference image: regenerated from the installers, never committed -------
# sfx_extract.py reads the ZIP archive appended to each self-extracting .exe (it
# never runs it); sld_decompress.py undoes the LZSS; smck_check.py checks the
# image against the block sums and the total the update floppy carries.
baserom: baserom/$(ROM)

baserom/$(EXE_A) baserom/$(EXE_B): | baserom/.dir
	$(PYTHON) $(TOOLS)/sfx_extract.py $(UPDATE) $(notdir $@) $@
baserom/$(SLD_A).SLD baserom/$(INF): baserom/$(EXE_A)
	$(PYTHON) $(TOOLS)/sfx_extract.py $< $(notdir $@) $@
baserom/$(SLD_B).SLD: baserom/$(EXE_B)
	$(PYTHON) $(TOOLS)/sfx_extract.py $< $(notdir $@) $@
baserom/%.bin: baserom/%.SLD
	$(PYTHON) $(TOOLS)/sld_decompress.py $< $@
baserom/$(ROM): baserom/$(SLD_A).bin baserom/$(SLD_B).bin baserom/$(INF)
	cat baserom/$(SLD_A).bin baserom/$(SLD_B).bin > $@
	$(PYTHON) $(TOOLS)/smck_check.py $@ baserom/$(INF) --expect match
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

# ---- symbols from the firmware's own MILK reflection tables --------------------
# Only tables whose procedures land in the code ranges count (README.md, "Symbols").
symbols $(MODEL).sym src/symbols.inc: $(TOOLS)/gen_symbols.py baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_symbols.py baserom/$(ROM) --program-base $(BASE) $(SYMRANGE) --no-manual \
	    --title "KN6500 program-image symbols recovered from the MILK toolkit" \
	    --inc-title "KN6500 symbols" --sym $(MODEL).sym --inc src/symbols.inc

# ---- regenerate src/program.s (needs unidasm) ------------------------------------
program-src: $(TOOLS)/gen_image_s.py $(MODEL).sym $(MODEL)_manual.sym src/symbols.inc baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_image_s.py --rom baserom/$(ROM) --base $(BASE) $(CODE) \
	    --sym $(MODEL).sym $(MODEL)_manual.sym --inc src/symbols.inc --labels-inc src/labels.inc \
	    --out src/program.s --unidasm $(UNIDASM) --stats notes/conversion-stats.txt \
	    --title $(TITLE) --title 'Panasonic MN10300, linked at 0x4C000000. See README.md.'

clean:
	rm -rf build

distclean: clean
	rm -rf baserom
