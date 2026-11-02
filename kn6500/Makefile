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
# the MN103002A on-chip registers and board I/O latches, by name (shared by every MN10300 tree)
SFR_INC  := ../kn7000/src/include/mn103002a_sfr.inc

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
# File-offset ranges that hold code (README.md, "Layout"): the boot header (its
# vectors), the start-up code and application after the erased 0x10-0x80 bytes,
# and the MILK kernel at the top of the image.
CODE     := --code 0x0:0xd --code 0x80:0x176839 --code 0x37e44c:0x381447 --code 0x381514:0x381691
# (lane generic-zero) the bytes between the code ranges, typed: the boot header's 0xFF pad,
# FirmwareVersionByte (func_4C07B3D7 answers it: 0x71 on v7.1, 0x13 on the KN6500's v1.3)
# and the erased flash before 0x80; after the MILK kernel its version string, the
# KernelServiceHash records func_4C3F7632 probes, the RAM layout words and the u16
# parameters the kernel reads ($(MODEL)_manual.sym says who reads each); then the kernel's
# interrupt dispatchers, code (the last --code range above).
TYPED    := --fill 0xd:0xf --rows 0xf:0x10:1:x --fill 0x10:0x80 --fill 0x381447:0x381448 --text 0x381448:0x381460 \
            --long-table 0x381460:0x3814e0 --long-table 0x3814e0:0x3814f8 --rows 0x3814f8:0x381514:2
SYMRANGE := --code-range 0x0:0x10 --code-range 0x80:0x176839 --code-range 0x37e44c:0x381447
TITLE    := 'Technics SX-KN6500 program flash image (update v1.3) - byte-exact.'
# The data region between the application's code and the MILK kernel, typed by
# ../kn7000/tools/gen_data_s.py --profile kn6500 (src/program/data/, README.md "The data").
DATA_LO  := 0x176839
DATA_HI  := 0x37e44c
DATA_DIR := src/program/data
DATA     := --data-src $(DATA_DIR)/data.s:$(DATA_LO):$(DATA_HI)
# the procedures the MILK function tables name (gen_data_s.py writes it; README.md "Symbols")
FN_SYM   := $(wildcard $(DATA_DIR)/functions.sym)
# the MILK ids the data defines, which the code's mov / cmp immediates are spelled with
IDS      := $(if $(wildcard $(DATA_DIR)/gui_code_ids.inc),--ids $(DATA_DIR)/gui_code_ids.inc)
DATA_FILES := $(wildcard $(DATA_DIR)/*.s $(DATA_DIR)/*.inc $(DATA_DIR)/media/*) src/constants.inc
# The bitmap resources are indexed PNGs in $(DATA_DIR)/media/ (gen_data_s.py bitmaps());
# ../kn7000/tools/table_png.py turns them back into the bytes the data .incbins from build/bitmaps/.
BITMAP_PNGS := $(wildcard $(DATA_DIR)/media/*.png)
# the KN7000 includes the typed demo songs use (kn_song.inc, panel_memory.inc ...)
SHARED_INCS := $(wildcard ../kn7000/src/include/*.inc)

.PHONY: all baserom build verify ported-names symbols program-src data-src data-and-code-src constants gui-map verify-gui-map clean distclean
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
build/bitmaps/.stamp: $(BITMAP_PNGS) $(TOOLS)/table_png.py
	@mkdir -p build/bitmaps
	$(PYTHON) $(TOOLS)/table_png.py build --out-dir build/bitmaps --src-root $(DATA_DIR)/media $(BITMAP_PNGS)
	@touch $@

build/$(ROM): src/program.s src/symbols.inc src/labels.inc $(DATA_FILES) $(SHARED_INCS) build/bitmaps/.stamp $(TOOLS)/kn7asm.py $(TOOLS)/mn10300_asm.py baserom/$(ROM)
	@mkdir -p build
	$(ASM) src/program.s -I . -o $@

build: build/$(ROM)

verify: build/$(ROM)
	@if cmp -s build/$(ROM) baserom/$(ROM); then \
	    echo "OK    $(ROM) is 100% byte-identical to the original"; \
	 else echo "FAIL  $(ROM) differs from the original:"; cmp build/$(ROM) baserom/$(ROM); exit 1; fi

# ---- symbols from the firmware's own MILK reflection tables --------------------
# Only tables whose procedures land in the code ranges count (README.md, "Symbols").
# The symbol files are committed sources: no rule has them as its target, so a build
# never regenerates them (a changed gen_symbols.py used to rewrite them in the middle
# of a gate).  `make symbols` regenerates them on purpose; `make symbols-check` writes
# the generator's output to build/symcheck/ and fails when it differs from them.
SYMOUT ?= .
.PHONY: symbols-check
symbols: baserom/$(ROM)
	@mkdir -p $(SYMOUT)/src
	$(PYTHON) $(TOOLS)/gen_symbols.py baserom/$(ROM) --program-base $(BASE) $(SYMRANGE) --no-manual \
	    --title "KN6500 program-image symbols recovered from the MILK toolkit" \
	    --inc-title "KN6500 symbols" --sym $(SYMOUT)/$(MODEL).sym --inc $(SYMOUT)/src/symbols.inc
symbols-check:
	rm -rf -- build/symcheck
	$(MAKE) --no-print-directory symbols SYMOUT=build/symcheck
	@ok=1; for f in $(MODEL).sym src/symbols.inc; do \
	    if cmp -s "build/symcheck/$$f" "$$f"; then echo "OK    $$f is what gen_symbols.py writes"; \
	    else echo "FAIL  $$f differs from gen_symbols.py's output (build/symcheck/$$f)"; ok=0; fi; done; \
	 [ $$ok -eq 1 ]

# ---- regenerate src/program.s (needs unidasm) ------------------------------------
program-src: $(TOOLS)/gen_image_s.py $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym src/symbols.inc $(SFR_INC) baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_image_s.py --rom baserom/$(ROM) --base $(BASE) $(CODE) --reflection-tables \
	    --sym $(MODEL).sym $(MODEL)_manual.sym $(MODEL)_ported.sym $(FN_SYM) --inc src/symbols.inc --labels-inc src/labels.inc \
	    --sfr-inc $(SFR_INC) --out src/program.s --unidasm $(UNIDASM) --stats notes/conversion-stats.txt $(DATA) $(IDS) --decode-gaps $(TYPED) \
	    --title $(TITLE) --title 'Panasonic MN10300, linked at 0x4C000000. See README.md.'

# ---- the data region as typed source (README.md, "The data") ---------------------
# gen_data_s.py reads the converted code (the MILK registrations, the data addresses it
# names) and writes $(DATA_DIR)/; gen_image_s.py names the code's data addresses with
# its labels.sym.  data-and-code-src runs the two alternately until labels.sym stops
# changing (../kn7000/tools/regen_sibling_data_and_code.sh).  The committed files are
# the result; the build does not need this.
# src/constants.inc is committed generated source (the firmware's own {name, value} tables as .equ
# lines; the assembly names them).  Only this maintenance target rewrites it, from the reference
# image; the build reads the committed file (lane media-cleanup, 2026-10-31: it used to be a file
# target, so every fresh clone regenerated it the moment the reference copy was newer).
.PHONY: constants
constants: $(TOOLS)/gen_constants.py baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_constants.py baserom/$(ROM) --base $(BASE) --scan 0x180000:0x1a0000 \
	    --model SX-KN6500 --inc src/constants.inc
data-src: $(TOOLS)/gen_data_s.py $(TOOLS)/milk_model.py src/constants.inc baserom/$(ROM)
	$(PYTHON) $(TOOLS)/gen_data_s.py --profile $(MODEL)
data-and-code-src: src/constants.inc baserom/$(ROM)
	$(TOOLS)/regen_sibling_data_and_code.sh $(MODEL) "$(MAKE) program-src UNIDASM=$(UNIDASM)"

# The GUI menu map (notes/gui-menu-map.md), generated from the typed data region's
# source by ../kn7000/tools/gui_menu_map.py; verify-gui-map fails when it is stale.
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

# (lane mn10300-names, 2026-11-02) then the sibling images, in this order, into what is still
# unnamed: their reflection names and hand names only (not their *_ported.sym, which came
# from the KN7000); the rows say '= KN6500 0x...'.  Needs their baserom/ (make -C ../<model> baserom).
PORT_SIBLINGS := --also-a KN6000 ../kn6000/baserom/kn6000_program.rom 0x4c000000 0x0:0xd,0x80:0x176037,0x3f47ec:0x3f77e7,0x3f78b4:0x3f7a31 ../kn6000/kn6000.sym,../kn6000/kn6000_manual.sym \
                 --also-a KN2400 ../kn2400/baserom/kn2400_program.rom 0x48400000 0x0:0xf,0x1e427c:0x3285be,0x3285be:0x3965b8:0x50120000 ../kn2400/kn2400.sym,../kn2400/kn2400_manual.sym

.PHONY: ported-names
ported-names: $(TOOLS)/port_names_by_code.py $(TOOLS)/gen_image_s.py src/labels.inc baserom/$(ROM)
	$(PYTHON) $(TOOLS)/port_names_by_code.py $(PORT_FROM) --b-rom baserom/$(ROM) --b-base $(BASE) \
	    $(subst --code,--b-code,$(CODE)) --b-sym $(MODEL).sym $(MODEL)_manual.sym \
	    --b-labels src/labels.inc --out $(MODEL)_ported.sym --unidasm $(UNIDASM) --fuzzy $(PORT_SIBLINGS) $(if $(PORT_CACHE),--cache $(PORT_CACHE)) \
	    --title "$(MODEL): names carried over from KN7000 program 941 and the sibling images (same code, relinked)"

clean:
	rm -rf build

distclean: clean
	rm -rf baserom
