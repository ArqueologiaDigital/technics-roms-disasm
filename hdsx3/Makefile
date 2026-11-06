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
# the MN103002A on-chip registers and board I/O latches, by name (shared by every MN10300 tree)
SFR_INC  := ../kn7000/src/include/mn103002a_sfr.inc

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
TYPED    := --decode-gaps --text 0x0:0x4 --long-table 0x4:0x80 --text 0xb655c:0xb6560 --fill 0xb6560:0xc0000 \
            --reflection-tables
# The data region (file 0x3ded6..0xb655c) is typed source, src/program/data/, generated
# by ../kn7000/tools/gen_data_s.py --profile hdsx3 (make data-src): the plug-in's own
# MILK classes and widget records (on the SX-KN6000's classes, read from ../kn6000),
# its function / event / method tables, strings and pictures.  Its labels.sym names the
# code's data addresses; data-and-code-src runs both generators to a fixpoint.
DATA_LO  := 0x3ded6
DATA_HI  := 0xb655c
DATA_DIR := src/program/data
DATA     := --data-src $(DATA_DIR)/data.s:$(DATA_LO):$(DATA_HI)
FN_SYM   := $(wildcard $(DATA_DIR)/functions.sym)
# the MILK ids the data defines (gen_data_s.py gui_code_ids.inc): the code's mov / cmp
# immediates equal to one are spelled with its name
IDS      := $(if $(wildcard $(DATA_DIR)/gui_code_ids.inc),--ids $(DATA_DIR)/gui_code_ids.inc)
# (lane mn10300-rest) the host routine of each `calls (aN)` through the host's registry, as a comment
IDS      += $(if $(wildcard $(DATA_DIR)/host_calls.tsv),--host-calls $(DATA_DIR)/host_calls.tsv)
# The bitmap resources are indexed PNGs in $(DATA_DIR)/media/ (gen_data_s.py bitmaps());
# ../kn7000/tools/table_png.py turns them back into the bytes the data .incbins from build/bitmaps/.
BITMAP_PNGS := $(wildcard $(DATA_DIR)/media/*.png)
# the KN7000 includes the typed demo songs use (kn_song.inc, panel_memory.inc ...)
SHARED_INCS := $(wildcard ../kn7000/src/include/*.inc)
DATA_FILES := $(wildcard $(DATA_DIR)/*.s $(DATA_DIR)/*.inc $(DATA_DIR)/media/*) ../kn6000/src/constants.inc

.PHONY: all baserom build verify ported-names symbols program-src clean distclean
.PHONY: data-src data-and-code-src gui-map verify-gui-map
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
build/bitmaps/.stamp: $(BITMAP_PNGS) $(TOOLS)/table_png.py
	@mkdir -p build/bitmaps
	$(PYTHON) $(TOOLS)/table_png.py build --out-dir build/bitmaps --src-root $(DATA_DIR)/media $(BITMAP_PNGS)
	@touch $@

build/$(ROM): src/program.s src/symbols.inc src/labels.inc $(DATA_FILES) $(SHARED_INCS) build/bitmaps/.stamp $(TOOLS)/kn7asm.py $(TOOLS)/mn10300_asm.py \
              baserom/$(ROM)
	@mkdir -p build
	$(ASM) src/program.s -I . -o $@

build: build/$(ROM)

verify: build/$(ROM)
	@if cmp -s build/$(ROM) baserom/$(ROM); then \
	    echo "OK    $(ROM) is 100% byte-identical to the original"; \
	 else echo "FAIL  $(ROM) differs from the original:"; cmp build/$(ROM) baserom/$(ROM); exit 1; fi

# ---- symbols from the plug-in's own MILK reflection tables -----------------------
# The symbol files are committed sources: no rule has them as its target, so a build
# never regenerates them (a changed gen_symbols.py used to rewrite them in the middle
# of a gate).  `make symbols` regenerates them on purpose; `make symbols-check` writes
# the generator's output to build/symcheck/ and fails when it differs from them.
SYMOUT ?= .
.PHONY: symbols-check
symbols: baserom/$(ROM)
	@mkdir -p $(SYMOUT)/src
	$(PYTHON) $(TOOLS)/gen_symbols.py baserom/$(ROM) --program-base $(BASE) $(SYMRANGE) --no-manual \
	    --title "XAPR plug-in (sx6-113 EXTAPR) symbols recovered from its MILK reflection tables" \
	    --inc-title "XAPR plug-in symbols" --sym $(SYMOUT)/$(MODEL).sym --inc $(SYMOUT)/src/symbols.inc
symbols-check:
	rm -rf -- build/symcheck
	$(MAKE) --no-print-directory symbols SYMOUT=build/symcheck
	@ok=1; for f in $(MODEL).sym src/symbols.inc; do \
	    if cmp -s "build/symcheck/$$f" "$$f"; then echo "OK    $$f is what gen_symbols.py writes"; \
	    else echo "FAIL  $$f differs from gen_symbols.py's output (build/symcheck/$$f)"; ok=0; fi; done; \
	 [ $$ok -eq 1 ]

# ---- regenerate src/program.s (needs unidasm) ------------------------------------
program-src: $(TOOLS)/gen_image_s.py $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym src/symbols.inc $(SFR_INC) baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_image_s.py --rom baserom/$(ROM) --base $(BASE) $(CODE) $(TYPED) $(DATA) \
	    --sym $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym $(NEW_SYM) $(FN_SYM) --inc src/symbols.inc \
	    --labels-inc src/labels.inc \
	    --sfr-inc $(SFR_INC) --out src/program.s --unidasm $(UNIDASM) --stats notes/conversion-stats.txt $(IDS) \
	    --title 'KN6000/KN6500 expansion-board XAPR plug-in (sx6-113 update, EXTAPR.SLD) - byte-exact.' \
	    --title 'Panasonic MN10300, linked at 0x97800000. See README.md.'

# ---- the typed data region (../kn7000/tools/gen_data_s.py) ------------------------
# It reads the SX-KN6000's model (../kn6000: its reference image, make -C ../kn6000
# baserom, and its source), whose classes the plug-in's records use.
data-src: $(TOOLS)/gen_data_s.py $(TOOLS)/milk_model.py baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_data_s.py --profile $(MODEL)
data-and-code-src: baserom/$(ROM)
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
	    $(subst --code,--b-code,$(CODE)) --b-sym $(MODEL).sym $(MODEL)_manual.sym $(NEW_SYM) \
	    --b-labels src/labels.inc --out $(MODEL)_ported.sym --unidasm $(UNIDASM) --fuzzy \
	    --title "$(MODEL): names carried over from KN7000 program 941 (same code, relinked)"

# ---- names carried along call sites and RAM operands; RAM names from their users ----------
# (lane open11/sibling-names, 2026-11-06; ../kn7000/notes/sibling-names/README.md)
# aligned-names: ../kn7000/tools/port_names_by_alignment.py carries KN7000 941 names onto the
# routines the two images' same-named routines call at aligned call sites, and onto same-body
# routines (short ones, twins) whose RAM operands the aligned anchors pair; it writes the RAM
# address pairs to notes/ram-map-kn7000.tsv.  ram-names: ../kn7000/tools/name_ram_by_use.py names
# the RAM addresses a named accessor (GetX / SetX / IsX) is the only access of, and those whose
# every direct reference lies in one named routine (R_Ram).  Order: aligned-names,
# data-and-code-src, ram-names, data-and-code-src.  The committed .sym files are the result.
ALIGNED_SYM := $(MODEL)_aligned.sym
RAM_SYM     := $(MODEL)_ram.sym
NEW_SYM     := $(wildcard $(ALIGNED_SYM) $(RAM_SYM))
.PHONY: aligned-names ram-names
aligned-names: $(TOOLS)/port_names_by_alignment.py $(TOOLS)/fn_similarity.py src/labels.inc baserom/$(ROM)
	$(PYTHON) $(TOOLS)/port_names_by_alignment.py $(PORT_FROM) --b-rom baserom/$(ROM) --b-base $(BASE) \
	    $(subst --code,--b-code,$(CODE)) --b-sym $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym $(FN_SYM) \
	    $(wildcard $(RAM_SYM)) --b-labels src/labels.inc --out $(ALIGNED_SYM) --ram-map notes/ram-map-kn7000.tsv --routine-map notes/routine-map-kn7000.tsv \
	    --report notes/aligned-names-report.md --unidasm $(UNIDASM) $(if $(PORT_CACHE),--cache $(PORT_CACHE)) \
	    --title "$(MODEL): KN7000 941 names carried along aligned call sites and RAM operands"
ram-names: $(TOOLS)/name_ram_by_use.py src/program.s
	$(PYTHON) $(TOOLS)/name_ram_by_use.py --src src/program.s \
	    --sym $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym $(wildcard $(ALIGNED_SYM)) $(FN_SYM) \
	    --taken src/labels.inc src/symbols.inc $(wildcard src/program/data/labels.sym src/constants.inc src/program/data/gui_code_ids.inc) \
	    --out $(RAM_SYM) --report notes/ram-names-report.md \
	    --title "$(MODEL): RAM addresses named after the named routines that use them"

clean:
	rm -rf build

distclean: clean
	rm -rf baserom
