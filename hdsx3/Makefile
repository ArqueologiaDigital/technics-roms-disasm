# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Rebuild the KN6000/KN6500 expansion-board "XAPR" plug-in image (Panasonic
# MN10300 code that the keyboard's own CPU runs from 0x97800000) from disassembly
# source and verify that the result is 100% byte-identical to the image the
# sx6-113 update installs. README.md says why the folder is called hdsx3 although
# the update is the HD-SX6's.
#
# The assembler and the helper scripts are the KN7000 tree's (../kn7000/tools);
# nothing is copied.

PYTHON   ?= python3
TOOLS    := ../kn7000/tools
ASM      := $(PYTHON) $(TOOLS)/kn7asm.py

# The Technics/Panasonic customer-service mirror beside this tree (private, not in
# git). sx6-113.zip holds the self-extracting floppy image of the board update.
# Override on the command line if it lives elsewhere: make CA_MIRROR=/path/files
CA_MIRROR ?= ../../ca-software-mirror/files
UPDATE    := $(CA_MIRROR)/6000/files/sx6-113.zip
EXE       := sx6v113a.exe

# MAME's unidasm; only `make program-src` needs it.
UNIDASM  ?= ../../tools/unidasm

MODEL    := hdsx3
ROM      := $(MODEL)_extapr.rom
BASE     := 0x97800000
# SHA-1 of the 786,432-byte image (EXTAPR.SLD, decompressed). The update carries
# no SMCK checksum file; this image is also md5 32ca36c8ed73813ea805d17ce57fd308,
# the private romset's hd-sx3_v1_1.bin.
ROM_SHA1 := 88699a7e9584e0c30c175babd1482e5aa586ad3d
# File-offset ranges that hold code (README.md, "Layout").
CODE     := --code 0x80:0x3ded6
SYMRANGE := --code-range 0x80:0x3ded6
# The XAPR header: the signature, then the entry vectors; and the second XAPR
# signature, at the end of the image, which header word +0x04 points at.
TYPED    := --text 0x0:0x4 --long-table 0x4:0x80 --text 0xb655c:0xb6560 --reflection-tables

.PHONY: all baserom build verify ported-names symbols program-src clean distclean
.DELETE_ON_ERROR:

all: verify

# ---- reference image: regenerated from the installer, never committed --------
baserom: baserom/$(ROM)

baserom/$(EXE): | baserom/.dir
	$(PYTHON) $(TOOLS)/sfx_extract.py $(UPDATE) $(EXE) $@
baserom/EXTAPR.SLD: baserom/$(EXE)
	$(PYTHON) $(TOOLS)/sfx_extract.py $< EXTAPR.SLD $@
baserom/$(ROM): baserom/EXTAPR.SLD
	$(PYTHON) $(TOOLS)/sld_decompress.py $< $@
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

# ---- symbols from the plug-in's own MILK reflection tables -----------------------
symbols $(MODEL).sym src/symbols.inc: $(TOOLS)/gen_symbols.py baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_symbols.py baserom/$(ROM) --program-base $(BASE) $(SYMRANGE) --no-manual \
	    --title "XAPR plug-in (sx6-113 EXTAPR) symbols recovered from its MILK reflection tables" \
	    --inc-title "XAPR plug-in symbols" --sym $(MODEL).sym --inc src/symbols.inc

# ---- regenerate src/program.s (needs unidasm) ------------------------------------
program-src: $(TOOLS)/gen_image_s.py $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym src/symbols.inc baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_image_s.py --rom baserom/$(ROM) --base $(BASE) $(CODE) $(TYPED) \
	    --sym $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym --inc src/symbols.inc --labels-inc src/labels.inc \
	    --out src/program.s --unidasm $(UNIDASM) --stats notes/conversion-stats.txt \
	    --title 'KN6000/KN6500 expansion-board XAPR plug-in (sx6-113 update, EXTAPR.SLD) - byte-exact.' \
	    --title 'Panasonic MN10300, linked at 0x97800000. See README.md.'

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

clean:
	rm -rf build

distclean: clean
	rm -rf baserom
