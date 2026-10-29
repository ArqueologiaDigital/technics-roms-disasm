# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Rebuild the Technics SX-KN6000 program flash image (Panasonic MN10300, MILK
# framework, linked at 0x4C000000) from disassembly source and verify that the
# result is 100% byte-identical to the image the manufacturer's v7.1 update
# installs.
#
# The assembler and the helper scripts are the KN7000 tree's (../kn7000/tools);
# nothing is copied.

PYTHON   ?= python3
TOOLS    := ../kn7000/tools
ASM      := $(PYTHON) $(TOOLS)/kn7asm.py

# The Technics/Panasonic customer-service mirror beside this tree (private, not in
# git). kn6-71.zip holds the two self-extracting floppy images of update v7.1.
# Override on the command line if it lives elsewhere: make CA_MIRROR=/path/files
CA_MIRROR ?= ../../ca-software-mirror/files
UPDATE    := $(CA_MIRROR)/6000/files/kn6-71.zip
EXE_A     := kn6-v7-1a.exe
EXE_B     := kn6-v7-1b.exe
SLD_A     := IK1
SLD_B     := IK2
INF       := SMCKPR1.INF

# MAME's unidasm; only `make program-src` needs it.
UNIDASM  ?= ../../tools/unidasm

MODEL    := kn6000
ROM      := $(MODEL)_program.rom
BASE     := 0x4c000000
# SHA-1 of the 4,160,049-byte image (IK1.SLD + IK2.SLD, decompressed, joined).
ROM_SHA1 := fa4cdb0618c18cdd549f067a388cabe3ecb8f9d4
# File-offset ranges that hold code (README.md, "Layout"): the boot header (its
# vectors), the start-up code and application after the erased 0x10-0x80 bytes,
# and the MILK kernel at the top of the image.
CODE     := --code 0x0:0x10 --code 0x80:0x176037 --code 0x3f47ec:0x3f77e7
SYMRANGE := --code-range 0x0:0x10 --code-range 0x80:0x176037 --code-range 0x3f47ec:0x3f77e7
TITLE    := 'Technics SX-KN6000 program flash image (update v7.1) - byte-exact.'

.PHONY: all baserom build verify ported-names symbols program-src clean distclean
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
	    --title "KN6000 program-image symbols recovered from the MILK toolkit" \
	    --inc-title "KN6000 symbols" --sym $(MODEL).sym --inc src/symbols.inc

# ---- regenerate src/program.s (needs unidasm) ------------------------------------
program-src: $(TOOLS)/gen_image_s.py $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym src/symbols.inc baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_image_s.py --rom baserom/$(ROM) --base $(BASE) $(CODE) --reflection-tables \
	    --sym $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym --inc src/symbols.inc --labels-inc src/labels.inc \
	    --out src/program.s --unidasm $(UNIDASM) --stats notes/conversion-stats.txt \
	    --title $(TITLE) --title 'Panasonic MN10300, linked at 0x4C000000. See README.md.'

# ---- names carried over from the KN7000 where a routine is the same code ---------
# port_names_by_code.py compares each unnamed entry with the KN7000 (program 941)
# routines its symbol files name, relocation-masked, entry to first return; only
# matches with >= 8 unmasked instructions, unique among all the KN7000's routine
# starts and among this image's entries, count (the tool's header has the rule). It
# reads the KN7000 reference image (../kn7000: make -C ../kn7000 baserom) and this
# tree's generated labels; run `make program-src` again afterwards. --fuzzy then compares
# whole routine bodies (../kn7000/tools/fn_similarity.py: classes exact / skeleton /
# fuzzy, each other's best match, no callee or string disagreeing) for what is left. The committed
# $(MODEL)_ported.sym is the result, so the build does not need the KN7000 image.
KN7000_DIR := ../kn7000
PORT_FROM  := --a-rom $(KN7000_DIR)/baserom/kn7000_program.rom \
              --a-code 0x80:0x186000 --a-code 0x3b8fd1:0x3f6f01:0x4c000000 \
              --a-sym $(KN7000_DIR)/kn7000_manual.sym $(KN7000_DIR)/kn7000_exports_from_942.sym \
                      $(KN7000_DIR)/kn7000.sym

.PHONY: ported-names
ported-names: $(TOOLS)/port_names_by_code.py $(TOOLS)/gen_image_s.py src/labels.inc baserom/$(ROM)
	$(PYTHON) $(TOOLS)/port_names_by_code.py $(PORT_FROM) --b-rom baserom/$(ROM) --b-base $(BASE) \
	    $(subst --code,--b-code,$(CODE)) --b-sym $(MODEL).sym $(MODEL)_manual.sym \
	    --b-labels src/labels.inc --out $(MODEL)_ported.sym --unidasm $(UNIDASM) --fuzzy \
	    --title "$(MODEL): names carried over from KN7000 program 941 (same code, relinked)"

# ---- the factory CUSTOM STYLE memory (IC18's bank at 0x96820000) ---------------
# The same format and the same firmware module as the KN7000's IC21 (0x4C16C013..
# here; ../kn7000/notes/custom-data-ic21.md). The one factory set is 01CTMINI.AST
# on the softlist floppy idd6000 (Initial Data Disk); inflated, it is the romset's
# 01ctmini.ic18, which the KN6500 romset carries too (same SHA-1).
# src/customdata/01ctmini.s is generated by ../kn7000/tools/gen_customdata_s.py
# (make customdata-src); its bulk items are .incbin_range of baserom/01ctmini.ic18.
SOFTLIST_DIR ?= $(HOME)/compartilhado/technics_romsets/floppy-rebuild-2026-10-18/roms
CD_SHA1      := 8c6d62a8afab717a2b59e9242bbf897b01369416

.PHONY: verify-customdata customdata-src
baserom/idd6000.img: | baserom/.dir
	unzip -p "$(SOFTLIST_DIR)/kn6000_flop/idd6000.zip" idd6000.img > $@.tmp
	mv $@.tmp $@
baserom/01ctmini.ast: baserom/idd6000.img $(TOOLS)/fat12_extract.py
	$(PYTHON) $(TOOLS)/fat12_extract.py $< 01CTMINI.AST $@
baserom/01ctmini.ic18: baserom/01ctmini.ast $(TOOLS)/ast_file.py
	$(PYTHON) $(TOOLS)/ast_file.py inflate $< $@.tmp
	echo "$(CD_SHA1)  $@.tmp" | sha1sum --quiet -c
	mv $@.tmp $@

build/01ctmini.ic18: src/customdata/01ctmini.s $(wildcard src/customdata/01ctmini/*.inc) ../kn7000/src/customdata/customdata.inc ../kn7000/src/include/panel_memory.inc ../kn7000/src/include/voice_record.inc $(TOOLS)/kn7asm.py baserom/01ctmini.ic18
	@mkdir -p build
	$(ASM) $< -I . -o $@

verify-customdata: build/01ctmini.ic18 baserom/01ctmini.ic18
	@if cmp -s build/01ctmini.ic18 baserom/01ctmini.ic18; then \
	    echo "OK    src/customdata/01ctmini.s rebuilds 01ctmini.ic18 byte-for-byte (SHA-1 $(CD_SHA1))"; \
	 else echo "FAIL  build/01ctmini.ic18 differs:"; cmp build/01ctmini.ic18 baserom/01ctmini.ic18; exit 1; fi

# Rebuild 01CTMINI.AST from the image with the programs' zlib 1.0.4 (../kn7000/tools/zlib10_deflate.py)
# and compare it with the floppy's file. Not part of the gate.
.PHONY: verify-customdata-ast
verify-customdata-ast: baserom/01ctmini.ic18 $(TOOLS)/ast_file.py $(TOOLS)/zlib10_deflate.py
	@mkdir -p build
	$(PYTHON) $(TOOLS)/ast_file.py deflate baserom/01ctmini.ic18 build/01ctmini.ast --like baserom/01ctmini.ast

customdata-src: $(TOOLS)/gen_customdata_s.py baserom/01ctmini.ic18
	$(PYTHON) $(TOOLS)/gen_customdata_s.py --rom baserom/01ctmini.ic18 --ref baserom/01ctmini.ic18 \
	    --out src/customdata/01ctmini.s --model kn6000 --include ../kn7000/src/customdata/customdata.inc --shared ../kn7000/src/include \
	    --title 'Technics SX-KN6000 / SX-KN6500 factory CUSTOM STYLE memory (IC18, bank 0x96820000) - byte-exact.' \
	    --title 'Reference: 01ctmini.ic18, the 0x1E0000-byte bank inflated from 01CTMINI.AST of the' \
	    --title 'MAME softlist kn6000_flop floppy idd6000 (../kn7000/tools/ast_file.py).'

clean:
	rm -rf build

distclean: clean
	rm -rf baserom
