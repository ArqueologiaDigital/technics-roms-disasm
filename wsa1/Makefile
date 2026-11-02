# Technics SX-WSA1R ROM disassembly -- LLVM build
#
# Mirrors the practice of ../kn5000-roms-disasm: the assembly sources are the
# authoritative form, and the ONLY thing that certifies them is that reassembling
# reproduces the original ROM byte for byte. Run the gate, never a percentage:
#
#     python3 scripts/analysis/assert_byte_identical.py
#
PROJECTS_ROOT ?= $(HOME)/compartilhado

LLVM_BIN=$(PROJECTS_ROOT)/llvm-project/build/bin
LLVM_MC=$(LLVM_BIN)/llvm-mc
LLVM_LLD=$(LLVM_BIN)/ld.lld -e 0
LLVM_OBJCOPY=$(LLVM_BIN)/llvm-objcopy

PROMS = a b c d

# ⚠ EVERY FILE AN IMAGE PULLS IN IS A PREREQUISITE.  The gate rebuilds before it
# compares, but `make` only rebuilds what it knows is stale: while these were
# missing, an edit to kernel/kernel.s left prom_c's object untouched and the gate
# passed on a stale build.  It was caught by a six-byte failure that survived the
# fix -- the fix had never been assembled.
KERNEL_SRC = kernel/kernel.s kernel/kernel_maincpu.inc kernel/kernel_subcpu.inc
COMMON_INC = include/tmp95c061_sfr.inc include/tlcs900_mem_ops.inc include/wsa1_ram.inc include/wsa1_gui.inc

# The DSP channel-register driver is ONE source too, included by prom_a at
# 0xF85F0F and by prom_c at 0xF98000 -- 234 bytes each, the same arrangement
# KERNEL_SRC has.  ⚠ BOTH images must list it, for the reason above: an edit to
# a file no rule names rebuilds nothing and the gate passes on a stale object.
DSP_SRC = dsp/dsp_channel_regs.s dsp/dsp_channel_regs_maincpu.inc \
          dsp/dsp_channel_regs_subcpu.inc

# The three routines prom_a and prom_b carry TWICE are one source each, included
# at both sites -- the same arrangement KERNEL_SRC has one level up, where one
# source serves two processors.  Both images must list them, for the reason the
# comment above gives.
MAINCPU_SHARED = maincpu/shared/indexed_table.s maincpu/shared/lcd_screen_redraw.s

# prom_c is no longer one file: since the per-subject split it is a master
# listing that `.include`s 26 subject sources in address order (the split, its
# rationale and its preservation proof are notes/prom_c_split.py).  A WILDCARD
# is used deliberately -- a hand-kept list is the same stale-build trap the
# comment above describes, one file further out, and it would go wrong silently.
# ⚠ THE MASTER MUST STAY FIRST: the recipe assembles `$<`.
PROM_C_SRC = prom_c/wsa1_prom_c.s \
             $(filter-out prom_c/wsa1_prom_c.s,$(wildcard prom_c/*.s prom_c/*/*.s))

# prom_a and prom_b are split the same way, one source per FIRMWARE MODULE: each
# root `.include`s prom_X/modules/*.s in address order (where a module ends, and
# the proof that the cut changes no byte: scripts/tools/split_cpu1_images.py).
# A wildcard again, for the reason above.  ⚠ THE ROOT MUST STAY FIRST: `$<`.
PROM_A_SRC = prom_a/wsa1_prom_a.s $(wildcard prom_a/modules/*.s)
PROM_B_SRC = prom_b/wsa1_prom_b.s $(wildcard prom_b/modules/*.s)

.PHONY: all clean images-check images-export images-sheet gui-menu-map gui-menu-map-check gui-census

# ---------------------------------------------------------------- the GUI index
# docs/gui-menu-map.md is GENERATED from the sources (every screen object, what it draws, its key map
# and the screen requests its handlers write): scripts/analysis/gui_menu_map.py says what it follows.
# The check is part of the root Makefile's gate-wsa1, after the byte gate has built the ELFs it reads.
gui-menu-map: all
	python3 scripts/analysis/gui_menu_map.py

gui-menu-map-check: all
	python3 scripts/analysis/gui_menu_map.py --check

# How much of the GUI data is still raw numbers (records, key maps, screen table), per image.
gui-census:
	python3 scripts/analysis/gui_readability_census.py

# ---------------------------------------------------------------- images
# Every ROM range that is pixel data is committed as a PNG beside the source (210 bitmaps and
# 12 font sheets, 95,342 bytes).  Since 2026-10-31 (lane media-build; the owner: "Images and wav
# files must be commited and the conversion must happen as a build step") the source holds no
# pixel rows: each range is an `.incbin "images/<name>.bin"`, and wsa1_bitmaps.py / wsa1_fonts.py
# `build` write those git-ignored .bin files from the PNGs.  They are real prerequisites of the
# prom_a / prom_b objects.  See notes/FINDINGS-image-files.md and
# ../notes/media-build-2026-10-31/README.md.
WSA1_IMAGE_BINS := $(shell python3 scripts/build/wsa1_bitmaps.py outputs)
$(WSA1_IMAGE_BINS) &: $(WSA1_IMAGE_BINS:.bin=.png) scripts/build/wsa1_bitmaps.py scripts/build/wsa1_fonts.py
	python3 scripts/build/wsa1_bitmaps.py build
	python3 scripts/build/wsa1_fonts.py build
	@touch $(WSA1_IMAGE_BINS)

# `images-check` (run by the root `make gate-wsa1`): every range is an .incbin of its built .bin,
# and every PNG decodes to the ROM's bytes (original_ROMs/ is committed for this model).
images-check:
	python3 scripts/build/wsa1_bitmaps.py check
	python3 scripts/build/wsa1_fonts.py check
	python3 scripts/build/wsa1_bitmaps.py verify
	python3 scripts/build/wsa1_fonts.py verify

# MAINTENANCE: rewrite every PNG from the ROMs (overwrites edits).
images-export:
	python3 scripts/build/wsa1_bitmaps.py export
	python3 scripts/build/wsa1_fonts.py export

# Browsing aids, not build inputs: the CONTACT_*.png sheets (git-ignored), made from the PNGs.
images-sheet:
	python3 scripts/build/wsa1_bitmaps.py sheet
.SECONDARY:

all: rebuilt_ROMs/wsa1_prom_a.llvm.rom rebuilt_ROMs/wsa1_prom_b.llvm.rom rebuilt_ROMs/wsa1_prom_c.llvm.rom rebuilt_ROMs/wsa1_prom_d.llvm.rom
# named here so a deleted .bin is made again (`.SECONDARY:` above makes every target intermediate)
all: $(WSA1_IMAGE_BINS)

rebuilt_ROMs/wsa1_prom_a.llvm.o: $(PROM_A_SRC) $(COMMON_INC) $(KERNEL_SRC) $(MAINCPU_SHARED) $(DSP_SRC) $(WSA1_IMAGE_BINS) $(LLVM_MC)
	@mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I . -I prom_a -o $@ $<


rebuilt_ROMs/wsa1_prom_b.llvm.o: $(PROM_B_SRC) $(COMMON_INC) $(MAINCPU_SHARED) $(WSA1_IMAGE_BINS) $(LLVM_MC)
	@mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I . -I prom_b -o $@ $<

# CPU 1's two EPROMs are ONE link (maincpu/maincpu.ld): a name either image uses for the
# other's code is resolved by ld.lld, not copied in as a number (scripts/tools/join_maincpu_link.py).
# The two images and the per-image ELF views the tools read are cut out of the one ELF.
# Each object exports exactly the labels the other image names (prom_X/exports.syms), made global
# AFTER assembly: declared `.global` in the source, a short branch to the label would be relaxed to
# its long form and change the bytes (the tool's docstring has the measurement).
rebuilt_ROMs/wsa1_prom_%.link.o: rebuilt_ROMs/wsa1_prom_%.llvm.o prom_%/exports.syms
	$(LLVM_OBJCOPY) --globalize-symbols=prom_$*/exports.syms $< $@

rebuilt_ROMs/wsa1_maincpu.llvm.elf: rebuilt_ROMs/wsa1_prom_b.link.o rebuilt_ROMs/wsa1_prom_a.link.o maincpu/maincpu.ld
	$(LLVM_LLD) -T maincpu/maincpu.ld -o $@ rebuilt_ROMs/wsa1_prom_b.link.o rebuilt_ROMs/wsa1_prom_a.link.o

MAINCPU_ELFS = rebuilt_ROMs/wsa1_prom_a.llvm.elf rebuilt_ROMs/wsa1_prom_b.llvm.elf
MAINCPU_ROMS = rebuilt_ROMs/wsa1_prom_a.llvm.rom rebuilt_ROMs/wsa1_prom_b.llvm.rom
$(MAINCPU_ELFS): rebuilt_ROMs/wsa1_prom_%.llvm.elf: rebuilt_ROMs/wsa1_maincpu.llvm.elf
	$(LLVM_OBJCOPY) -j .prom_$* $< $@
# scripts/analysis/gui_menu_map.py (the gate-wsa1 check) reads these two ELFs; `all` names them so a
# fresh tree has them after the byte gate's `make all` (2026-11-02: without them the check stopped
# with "build first" in a new worktree).
all: $(MAINCPU_ELFS)

$(MAINCPU_ROMS): rebuilt_ROMs/wsa1_prom_%.llvm.rom: rebuilt_ROMs/wsa1_maincpu.llvm.elf
	$(LLVM_OBJCOPY) -O binary -j .prom_$* $< $@

rebuilt_ROMs/wsa1_prom_c.llvm.o: $(PROM_C_SRC) $(COMMON_INC) $(KERNEL_SRC) $(DSP_SRC) $(LLVM_MC)
	@mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I . -I prom_c -o $@ $<

rebuilt_ROMs/wsa1_prom_c.llvm.elf: rebuilt_ROMs/wsa1_prom_c.llvm.o prom_c/prom_c.ld
	$(LLVM_LLD) -T prom_c/prom_c.ld -o $@ $<

rebuilt_ROMs/wsa1_prom_c.llvm.rom: rebuilt_ROMs/wsa1_prom_c.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# prom_d is FOUR files: wsa1_prom_d.s is the header plus three .include lines.
# Mirrors ../kn5000-roms-disasm/table_data/, which splits the same database the
# same way.  All three parts are prerequisites -- see the warning above; an
# include that is not listed here rebuilds nothing and the gate passes stale.
PROM_D_PARTS = prom_d/tone_database_directory.s prom_d/tone_database_records.s \
               prom_d/tone_database_aux.s

rebuilt_ROMs/wsa1_prom_d.llvm.o: prom_d/wsa1_prom_d.s $(PROM_D_PARTS) $(COMMON_INC) $(LLVM_MC)
	@mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I . -I prom_d -o $@ $<

rebuilt_ROMs/wsa1_prom_d.llvm.elf: rebuilt_ROMs/wsa1_prom_d.llvm.o prom_d/prom_d.ld
	$(LLVM_LLD) -T prom_d/prom_d.ld -o $@ $<

rebuilt_ROMs/wsa1_prom_d.llvm.rom: rebuilt_ROMs/wsa1_prom_d.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

clean:
	rm -rf rebuilt_ROMs
