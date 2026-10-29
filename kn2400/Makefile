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

MODEL    := kn2400
ROM      := $(MODEL)_program.rom
BASE     := 0x48400000
# SHA-1 of the 3,761,619-byte image (LKG1.SLD + LKG2.SLD, decompressed, joined).
ROM_SHA1 := 39163ea892baf8ad11419c29fe58cc536bef9ca7
# File-offset ranges that hold code (LO:HI, or LO:HI:CPU when the range is linked
# for another address than its flash one): the boot vectors; the code linked for
# flash, from the MILK kernel (after the data, which ends with the MILK banner and
# a table of words at 0x1e41c8-0x1e427c) to 0x3285be; and the code linked for work RAM at
# 0x50120000, which runs from 0x3285be to the 24-byte trailer at the end of the
# image (README.md, "Layout"). The data comes first in this image.
CODE     := --code 0x0:0xf --code 0x1e427c:0x3285be --code 0x3285be:0x3965b8:0x50120000

# The data region (file 0x0f..0x1e427c) is typed source, src/program/data/, generated
# by ../kn7000/tools/gen_data_s.py --profile kn2400 (make data-src): the MILK classes,
# widget records, reflection tables, strings and media.  Its labels.sym names the
# code's data addresses.  data-and-code-src runs both generators to a fixpoint.
# --decode-gaps disassembles the code no traced path reaches; the 27 bytes after the
# RAM-linked code (RamCodeTrailer, kn2400_manual.sym) are typed rows.
DATA_LO  := 0xf
DATA_HI  := 0x1e427c
DATA_DIR := src/program/data
DATA     := --decode-gaps --text 0x3965b8:0x3965bf --long-table 0x3965bf:0x3965d3 \
            --data-src $(DATA_DIR)/data.s:$(DATA_LO):$(DATA_HI)
FN_SYM   := $(wildcard $(DATA_DIR)/functions.sym)
DATA_FILES := $(wildcard $(DATA_DIR)/*.s $(DATA_DIR)/*.inc $(DATA_DIR)/media/*) src/constants.inc

.PHONY: all baserom build verify ported-names verify-kn2600 symbols program-src clean distclean
.PHONY: data-src constants data-and-code-src gui-map verify-gui-map
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
build/$(ROM): src/program.s src/symbols.inc src/labels.inc $(DATA_FILES) $(TOOLS)/kn7asm.py $(TOOLS)/mn10300_asm.py \
              baserom/$(ROM)
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
	    --code-range 0x1e427c:0x3285be --no-manual \
	    --title "KN2400/KN2600 program-image symbols recovered from the MILK toolkit" \
	    --inc-title "KN2400/KN2600 symbols" --sym kn2400.sym --inc src/symbols.inc

# ---- regenerate src/program.s (needs unidasm) ------------------------------------
program-src: $(TOOLS)/gen_image_s.py $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym src/symbols.inc baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_image_s.py --rom baserom/$(ROM) --base 0x48400000 $(CODE) --reflection-tables $(DATA) \
	    --sym $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym $(FN_SYM) --inc src/symbols.inc \
	    --labels-inc src/labels.inc --out src/program.s \
	    --unidasm $(UNIDASM) --stats notes/conversion-stats.txt \
	    --title 'Technics SX-KN2400 / SX-KN2600 program flash image (update v1.1) - byte-exact.' \
	    --title 'Panasonic MN10300, linked at 0x48400000. See README.md.'

# ---- the typed data region (../kn7000/tools/gen_data_s.py) ------------------------
# constants: the MILK framework's own {name, value} tables (CL_ BD_ ES_ VF_ ...), at
# file 0x15000..0x17000 in this image.
constants src/constants.inc: $(TOOLS)/gen_constants.py baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_constants.py baserom/$(ROM) --base $(BASE) --scan 0x15000:0x17000 \
	    --model SX-KN2400/KN2600 --inc src/constants.inc > /dev/null
data-src: $(TOOLS)/gen_data_s.py $(TOOLS)/milk_model.py baserom/$(ROM) src/constants.inc
	$(PYTHON) $(TOOLS)/gen_data_s.py --profile $(MODEL)
data-and-code-src: src/constants.inc baserom/$(ROM)
	$(TOOLS)/regen_sibling_data_and_code.sh $(MODEL) "$(MAKE) program-src UNIDASM=$(UNIDASM)"

# The menu map, generated from the data region's source (../kn7000/tools/gui_menu_map.py).
gui-map:
	$(PYTHON) $(TOOLS)/gui_menu_map.py --profile $(MODEL)
verify-gui-map:
	@$(PYTHON) $(TOOLS)/gui_menu_map.py --profile $(MODEL) --check

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
