# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Rebuild the Technics SX-KN7000 flash images from disassembly source and verify
# that the result is 100% byte-identical to the images extracted from the
# original system-update floppy disks.

PYTHON      ?= python3
ASM         := $(PYTHON) tools/kn7asm.py

# Sibling repo that extracts the reference images from the update disks, and the
# original disk contents it reads. Override on the command line if they live
# elsewhere, e.g.  make EXTRACT_DIR=/path/to/kn7000_extraction
EXTRACT_DIR ?= ../../kn7000_extraction
DISKS_DIR   ?= ../../KN7000

# SP7001 variant: its reference images come from the raw EPROM-half dumps in the
# (private) MAME romset, de-interleaved by tools/rom_from_eproms.py — not from
# the update disks. Override if the romset lives elsewhere.
ROMSET_DIR  ?= ../../technics_romsets/kn7000
# ...and the SP7001 update itself: four self-extracting ZIP "disks" (program 1/2,
# 2/2, table 1/2, 2/2), read with tools/sfx_extract.py (never executed).
SP7001_UPDATES ?= ../../nonfree/kn7000-sp7001/sp7001-kn7000-updates
SP7001_TB1  := $(SP7001_UPDATES)/table1_2.exe
SP7001_TB2  := $(SP7001_UPDATES)/table2_2PLUG-iN.exe
SP7001_PR1  := $(SP7001_UPDATES)/PROGR1_2v1.6PLUG-iN.exe
SP7001_PR2  := $(SP7001_UPDATES)/PROGR2_2v1.6PLUG-iN.exe

# MAME's unidasm, used only by `make disasm` to (re)generate the reference
# listings. Point this at your MAME build's unidasm binary.
UNIDASM     ?= ../../mame-sony-video/unidasm

TARGETS     := build/kn7000_program.rom build/kn7000_table.rom
REFS        := baserom/kn7000_program.rom baserom/kn7000_table.rom

.PHONY: all verify verify-listings disasm disasm-dsp symbols program-src constants clean distclean baserom

# Default: build then verify byte-for-byte.
all: verify

# ---- reference images (extracted from the update disks) --------------------
# Produced by the sibling kn7000_extraction repo. Kept out of git (see
# .gitignore); regenerated on demand from the original disks.
baserom: $(REFS)

baserom/kn7000_program.rom baserom/kn7000_table.rom &:
	@echo "==> extracting reference images via $(EXTRACT_DIR)"
	@if [ -x "$(EXTRACT_DIR)/venv/bin/python" ]; then \
	    PY="$(EXTRACT_DIR)/venv/bin/python"; \
	 else \
	    PY="$(PYTHON)"; \
	 fi; \
	 "$$PY" "$(EXTRACT_DIR)/kn7000_extract.py" "$(DISKS_DIR)" "$(EXTRACT_DIR)/output"
	@mkdir -p baserom
	@cp "$(EXTRACT_DIR)/output/kn7000_program.rom" baserom/kn7000_program.rom
	@cp "$(EXTRACT_DIR)/output/kn7000_table.rom"   baserom/kn7000_table.rom

# ---- build -----------------------------------------------------------------
# --labels: the previous build's label addresses seed kn7asm's first pass (only
# an estimate -- the passes still run until one is exact -- so a fully
# converted program assembles in about one pass instead of five).
# The program data regions' bitmaps are indexed PNGs in <data dir>/media/ (gen_data_s.py
# bitmaps() / drawn_bitmaps()); tools/table_png.py turns them back into the bytes the data
# .incbins from build/bitmaps/<build>/ (one stamp per program build).
# $(1) = the build's name in gen_data_s.py, $(2) = its data directory
define PROGRAM_BITMAPS
build/bitmaps/$(1)/.stamp: $$(wildcard $(2)/media/*.png) tools/table_png.py
	@mkdir -p build/bitmaps/$(1)
	$$(PYTHON) tools/table_png.py build --out-dir build/bitmaps/$(1) --src-root $(2)/media $$(wildcard $(2)/media/*.png)
	@touch $$@
endef
$(eval $(call PROGRAM_BITMAPS,941,src/program/data))
$(eval $(call PROGRAM_BITMAPS,sp7001,src/sp7001/program/data))
$(eval $(call PROGRAM_BITMAPS,b935,src/b935/program/data))
$(eval $(call PROGRAM_BITMAPS,b893,src/b893/program/data))

build/kn7000_program.rom: src/program.s $(wildcard src/program/*.s) $(wildcard src/program/data/*) src/symbols.inc \
		src/constants.inc tools/kn7asm.py baserom/kn7000_program.rom build/bitmaps/941/.stamp
	@mkdir -p build
	$(ASM) src/program.s -I . -o $@ --labels build/kn7000_program.labels

# ---- recover symbols from the firmware's MILK-toolkit reflection tables -----
# Names 444 functions (shared with the KN5000). Regenerates kn7000.sym and the
# src/symbols.inc that src/program.s includes.
#
# The symbol files are committed SOURCES: no rule has them as its target, so a
# build never regenerates them implicitly (a changed generator used to rewrite them
# in the middle of a gate).  `make symbols` (941), `symbols-sp7001`, `exports-941`,
# `symbols-935` and `symbols-893` regenerate them on purpose; `make symbols-check`
# runs the same recipes into build/symcheck/ (SYMOUT) and fails when any output
# differs from the committed file.  Each recipe reads the committed inputs, so the
# check compares every step on its own.
SYMOUT ?= .
SYMCHECK := build/symcheck
SYMBOL_FILES := kn7000.sym src/symbols.inc \
    kn7000_sp7001.sym src/sp7001/symbols.inc kn7000_sp7001_manual.sym kn7000_sp7001_exports.sym \
    kn7000_sp7001_table.sym src/sp7001/table_symbols.inc kn7000_exports_from_942.sym \
    kn7000_b935.sym src/b935/symbols.inc kn7000_b935_manual.sym kn7000_b935_exports.sym \
    kn7000_b893.sym src/b893/symbols.inc kn7000_b893_manual.sym kn7000_b893_exports.sym
.PHONY: symbols symbols-check
symbols:
	@mkdir -p $(SYMOUT)/src
	$(PYTHON) tools/gen_symbols.py baserom/kn7000_program.rom --sym $(SYMOUT)/kn7000.sym --inc $(SYMOUT)/src/symbols.inc
symbols-check:
	rm -rf -- $(SYMCHECK)
	$(MAKE) --no-print-directory symbols symbols-sp7001 exports-941 symbols-935 symbols-893 SYMOUT=$(SYMCHECK)
	@ok=1; for f in $(SYMBOL_FILES); do \
	    if cmp -s "$(SYMCHECK)/$$f" "$$f"; then echo "OK    $$f is what its generator writes"; \
	    else echo "FAIL  $$f differs from its generator's output ($(SYMCHECK)/$$f)"; ok=0; fi; done; \
	 [ $$ok -eq 1 ]

# Regenerate src/program.s and its parts in src/program/ (code region 1 and the
# library image as MN10300 assembly; tools/gen_program_s.py, needs unidasm,
# about 3 minutes). The committed source is the byte-exact result; the build
# does not need this.
# Recover the MILK framework's named-constant tables (colours, view flags, ...)
# into a reference listing + an assembler include.
# src/constants.inc is committed generated source (the firmware's own {name, value} tables as .equ
# lines; the assembly names them).  Only this maintenance target rewrites it, from the reference
# image; the build reads the committed file (lane media-cleanup, 2026-10-31: it used to be a file
# target, so every fresh clone regenerated it the moment the reference copy was newer).
constants: tools/gen_constants.py baserom/kn7000_program.rom
	$(PYTHON) tools/gen_constants.py baserom/kn7000_program.rom --inc src/constants.inc

program-src: tools/gen_program_s.py tools/mn10300_asm.py kn7000.sym kn7000_manual.sym \
		kn7000_exports_from_942.sym $(wildcard annotations/*.ann) baserom/kn7000_program.rom
	UNIDASM=$(UNIDASM) $(PYTHON) tools/gen_program_s.py

# Regenerate src/program/data/, the data region (file 0x186000..0x3B8FD1) as typed
# source: the MILK class / object / name tables and the widget records as macros,
# strings, pointer tables (tools/gen_data_s.py, tools/milk_model.py; reads the
# converted code and build/kn7000_program.labels, so build first). The committed
# files are the result; the build does not need this.
# data-src-<build> does the same for builds 942 (sp7001), 935 and 893, into
# src/<build>/program/data/, from that build's image, converted code and labels.
# data-and-code-src runs data-src* and program-src* alternately for all four
# builds until they agree (tools/regen_data_and_code.sh): the code names data
# addresses with the labels the data generation gives them.
.PHONY: data-src data-src-sp7001 data-src-935 data-src-893 data-and-code-src
data-and-code-src:
	UNIDASM=$(UNIDASM) tools/regen_data_and_code.sh
data-src: tools/gen_data_s.py tools/milk_model.py baserom/kn7000_program.rom build/kn7000_program.rom
	$(PYTHON) tools/gen_data_s.py
data-src-sp7001: tools/gen_data_s.py tools/milk_model.py build/kn7000_program_sp7001.rom
	$(PYTHON) tools/gen_data_s.py --profile sp7001
data-src-935: tools/gen_data_s.py tools/milk_model.py build/kn7000_program_b935.rom
	$(PYTHON) tools/gen_data_s.py --profile b935
data-src-893: tools/gen_data_s.py tools/milk_model.py build/kn7000_program_b893.rom
	$(PYTHON) tools/gen_data_s.py --profile b893

# The GUI menu map (notes/gui-data-region/menu-map.md), generated from the typed
# data region's source by tools/gui_menu_map.py; verify-gui-map fails when it is stale.
.PHONY: gui-map verify-gui-map
gui-map:
	$(PYTHON) tools/gui_menu_map.py
	$(PYTHON) tools/gui_menu_map.py --profile sp7001plugin
verify-gui-map:
	@$(PYTHON) tools/gui_menu_map.py --check
	@$(PYTHON) tools/gui_menu_map.py --profile sp7001plugin --check

# The table image's pictures live in src/table/: the 57 JPEG segments, and in
# subdirectories the JPEG/BMP items of the picture-group segments. The same files
# serve the SP7001 table, whose copies are identical; the rest comes from baserom/.
TABLE_JPGS := $(wildcard src/table/*.jpg src/table/*/*.jpg src/table/*/*.bmp)

# The raw pictures (GUI bitmaps, frame pieces, icons, fonts, TCD and USER HP menu
# pictures) are indexed PNGs in src/table/<subdir>/; tools/table_png.py turns them back
# into the bytes the table sources .incbin from build/table_png/ (one stamp for all).
TABLE_PNGS := $(sort $(wildcard src/table/*/*.png))
# The style data's include files (tools/gen_table_styles.py) and their macros.
TABLE_INCS := $(wildcard src/table/*.inc src/table/styles/*.s src/table/styles/*/*.s src/table/pads/*.s src/table/voices/*.s)
build/table_png/.stamp: $(TABLE_PNGS) tools/table_png.py
	@mkdir -p build/table_png
	$(PYTHON) tools/table_png.py build --out-dir build/table_png $(TABLE_PNGS)
	@touch $@

build/kn7000_table.rom: src/table.s $(TABLE_JPGS) $(TABLE_INCS) build/table_png/.stamp tools/kn7asm.py baserom/kn7000_table.rom
	@mkdir -p build
	$(ASM) src/table.s -I . -o $@

# Regenerate src/table.s and src/table/ from build 84's image: the directory as
# offsets to labelled segments, names and comments from tools/table_segments.py. The
# committed files are the result; the build does not need this.
.PHONY: table-src
table-src: tools/gen_table_s.py tools/table_segments.py tools/table_png.py tools/gen_table_styles.py baserom/kn7000_table.rom
	$(PYTHON) tools/gen_table_s.py --rom baserom/kn7000_table.rom --out src/table.s \
	    --jpg-dir src/table --title 'KN7000 "Table" flash image (build 84) - byte-exact.'

build: $(TARGETS)

# ---- verify (the whole point: 100% byte-match) -----------------------------
verify: $(TARGETS)
	@ok=1; \
	for name in kn7000_program.rom kn7000_table.rom; do \
	  if cmp -s "build/$$name" "baserom/$$name"; then \
	    echo "OK    $$name is 100% byte-identical to the original"; \
	  else \
	    echo "FAIL  $$name differs from the original:"; \
	    cmp "build/$$name" "baserom/$$name" || true; \
	    ok=0; \
	  fi; \
	done; \
	[ $$ok -eq 1 ] || { echo; echo "byte-match FAILED"; exit 1; }
	@echo; echo "All images reproduced byte-for-byte."

# ---- check the CURATED listings under disasm/ ------------------------------
# The hand-annotated listings are not part of the byte-exact build, so nothing
# else would catch a typo in them. verify_listing.py re-reads every byte column
# straight out of baserom/ and re-encodes every mnemonic with the repo's own
# MN10300 encoder, so a wrong byte or a wrong operand fails here.
CURATED_LISTINGS := disasm/debugger_memdump.asm

verify-listings: baserom/kn7000_program.rom tools/verify_listing.py tools/mn10300_asm.py
	$(PYTHON) tools/verify_listing.py $(CURATED_LISTINGS)

# ---- (re)generate the reference disassembly listings -----------------------
disasm: disasm/program.asm disasm/program_region2.asm disasm/program_named.asm disasm/table_directory.asm disasm-dsp

# ---- effects-DSP (IC306 ADSP-21065L) host-download record pool --------------
# 80 SHARC programs embedded in the program image at file 0x2BCEC4..0x2CE68D.
# Extract + disassemble (unidasm -arch sharc), merging curated annotation from
# dsp/records.tsv and dsp/sym/*.sym. The listings under disasm/dsp/ are tracked;
# build/dsp/*.bin raw extracts are not (see .gitignore /build/). See dsp/README.md.
DSP_POOL := 0x2BCEC4 0x2CE68D

.PHONY: disasm-dsp
disasm-dsp: baserom/kn7000_program.rom tools/gen_dsp_records.py \
            dsp/records.tsv $(wildcard dsp/sym/*.sym)
	@mkdir -p disasm/dsp build/dsp
	@echo "==> extracting + disassembling the SHARC record pool ($(DSP_POOL))"
	@$(PYTHON) tools/gen_dsp_records.py --rom $< --pool $(DSP_POOL) \
	    --unidasm $(UNIDASM) --manifest dsp/records.tsv --symdir dsp/sym \
	    --bindir build/dsp --out disasm/dsp
	@echo "wrote disasm/dsp/"

disasm/program.asm: baserom/kn7000_program.rom
	@mkdir -p disasm
	@echo "==> disassembling program code region 1 (0x80..0x186000) with unidasm"
	@$(UNIDASM) $< -arch mn10300 -basepc 0x48400080 -skip 0x80 \
	    -count $$((0x186000 - 0x80)) > $@
	@echo "wrote $@"

# Code region 2 (the MILK kernel + late drivers) lives high in the image and was
# never in the region-1 sweep above. CPU 0x487B8D00..0x487F6F01, file 0x3B8D00.
disasm/program_region2.asm: baserom/kn7000_program.rom
	@mkdir -p disasm
	@echo "==> disassembling program code region 2 (0x487B8D00..0x487F6F01) with unidasm"
	@$(UNIDASM) $< -arch mn10300 -basepc 0x487B8D00 -skip 0x3B8D00 \
	    -count $$((0x3F6F01 - 0x3B8D00)) > $@
	@echo "wrote $@"

# Named, function-by-function disassembly using the recovered symbols.
disasm/program_named.asm: baserom/kn7000_program.rom kn7000.sym kn7000_manual.sym \
		kn7000_exports_from_942.sym tools/disasm_functions.py
	@mkdir -p disasm build
	@echo "==> named function disassembly with unidasm (generated + manual symbols)"
	@cat kn7000.sym kn7000_manual.sym kn7000_exports_from_942.sym > build/kn7000_merged.sym
	@$(PYTHON) tools/disasm_functions.py --rom $< --sym build/kn7000_merged.sym \
	    --unidasm $(UNIDASM) > $@
	@echo "wrote $@"

# The table image is data, not code; provide its directory as a listing.
disasm/table_directory.asm: baserom/kn7000_table.rom tools/dump_table_dir.py
	@mkdir -p disasm
	$(PYTHON) tools/dump_table_dir.py $< > $@
	@echo "wrote $@"

# ---- IC19, the picture ROM (the 100 Slide Show PRESET pictures) -------------
# Unlike the flash images, this source carries its data: src/picture.s includes the
# 100 JPEGs in src/picture/ (tools/gen_picture_s.py wrote both from a read of the
# chip). So it builds and checks without any reference image: the result must have
# the SHA-1 of the 2 MB the CPU sees at 0x57800000 on the real instrument. With the
# read itself at hand (PICTURE_REF, the 8 MB the ROM dumper wrote, private), it is
# also compared byte for byte, all four 2 MB copies of the window.
# See notes/ic19-picture-rom.md.
PICTURE_SHA1 := 9631dedfc501b8c11bb93efa2d99750e3c84465a
PICTURE_REF  ?= ../../technics_roms/roms/kn7000/real_dump_v1.3_b893/pass2-run1/IC19.BIN

.PHONY: verify-picture picture-src
build/kn7000_picture.rom: src/picture.s $(wildcard src/picture/*.jpg) tools/kn7asm.py
	@mkdir -p build
	$(ASM) src/picture.s -I . -o $@

verify-picture: build/kn7000_picture.rom
	@if [ "$$(sha1sum < $< | cut -d' ' -f1)" = "$(PICTURE_SHA1)" ]; then \
	    echo "OK    kn7000_picture.rom has the SHA-1 of the instrument's IC19 ($(PICTURE_SHA1))"; \
	 else echo "FAIL  kn7000_picture.rom: SHA-1 is not $(PICTURE_SHA1)"; exit 1; fi
	@if [ -f "$(PICTURE_REF)" ]; then \
	    for k in 0 1 2 3; do \
	      cmp -s -n 2097152 -i 0:$$((k * 2097152)) $< "$(PICTURE_REF)" || { echo "FAIL  copy $$k of $(PICTURE_REF) differs"; exit 1; }; \
	    done; echo "OK    and it equals all four 2 MB copies in $(PICTURE_REF)"; \
	 else echo "(no $(PICTURE_REF): only the SHA-1 was checked)"; fi

# Regenerate src/picture.s and src/picture/*.jpg from a read of IC19.
picture-src: tools/gen_picture_s.py
	$(PYTHON) tools/gen_picture_s.py "$(PICTURE_REF)"

# ---- SP7001 variant (program build 942 / table build 83) -------------------
# A second byte-exact target. Its reference images are the de-interleaved raw
# EPROM dumps; the source currently passes them through verbatim and is refined
# only on the SP7001-unique code. See notes/sp7001-build-diff.md.
SP7001_TARGETS := build/kn7000_program_sp7001.rom build/kn7000_table_sp7001.rom \
                  build/sp7001_baseext.xap

.PHONY: baserom-sp7001 build-sp7001 verify-sp7001
baserom-sp7001: baserom/kn7000_program_sp7001.rom baserom/kn7000_table_sp7001.rom

baserom/kn7000_program_sp7001.rom: tools/rom_from_eproms.py
	@mkdir -p baserom
	$(PYTHON) tools/rom_from_eproms.py \
	    "$(ROMSET_DIR)/kn7000_program_even_sp7001_b942.ic17" \
	    "$(ROMSET_DIR)/kn7000_program_odd_sp7001_b942.ic16" $@

baserom/kn7000_table_sp7001.rom: tools/rom_from_eproms.py
	@mkdir -p baserom
	$(PYTHON) tools/rom_from_eproms.py \
	    "$(ROMSET_DIR)/kn7000_table_even_sp7001_b83.ic17" \
	    "$(ROMSET_DIR)/kn7000_table_odd_sp7001_b83.ic16" $@

build/kn7000_program_sp7001.rom: src/sp7001/program.s $(wildcard src/sp7001/program/*.s) \
		$(wildcard src/sp7001/program/data/*) src/constants.inc src/sp7001/symbols.inc tools/kn7asm.py \
		baserom/kn7000_program_sp7001.rom build/bitmaps/sp7001/.stamp
	@mkdir -p build
	$(ASM) src/sp7001/program.s -I . -o $@ --labels build/kn7000_program_sp7001.labels

build/kn7000_table_sp7001.rom: src/sp7001/table.s $(TABLE_JPGS) $(TABLE_INCS) src/sp7001/internal_voice_archive.s \
		$(wildcard src/sp7001/plugin/data/*) build/table_png/.stamp tools/kn7asm.py baserom/kn7000_table_sp7001.rom
	@mkdir -p build
	$(ASM) src/sp7001/table.s -I . -o $@ --labels build/kn7000_table_sp7001.labels

build/sp7001_baseext.xap: src/sp7001/baseext.s tools/kn7asm.py baserom/sp7001_baseext.xap
	@mkdir -p build
	$(ASM) src/sp7001/baseext.s -I . -o $@

build-sp7001: $(SP7001_TARGETS)

# ---- the SP7001 table update disks -----------------------------------------
baserom/sp7001_baseext.xap: tools/sfx_extract.py
	@mkdir -p baserom
	$(PYTHON) tools/sfx_extract.py $(SP7001_TB2) BASEEXT.XAP $@
baserom/sp7001_tb1_smck.inf: tools/sfx_extract.py
	@mkdir -p baserom
	$(PYTHON) tools/sfx_extract.py $(SP7001_TB1) SMCKTB1.INF $@
baserom/sp7001_tb2_smck.inf: tools/sfx_extract.py
	@mkdir -p baserom
	$(PYTHON) tools/sfx_extract.py $(SP7001_TB2) SMCKTB2.INF $@
baserom/sp7001_tb1_jkt1.sld: tools/sfx_extract.py
	@mkdir -p baserom
	$(PYTHON) tools/sfx_extract.py $(SP7001_TB1) JKT1.SLD $@
baserom/sp7001_tb2_jktbl2.sld: tools/sfx_extract.py
	@mkdir -p baserom
	$(PYTHON) tools/sfx_extract.py $(SP7001_TB2) JKTBL2.SLD $@
baserom/sp7001_pr1_hama1.sld: tools/sfx_extract.py
	@mkdir -p baserom
	$(PYTHON) tools/sfx_extract.py $(SP7001_PR1) HAMA1.SLD $@
baserom/sp7001_pr2_hama2.sld: tools/sfx_extract.py
	@mkdir -p baserom
	$(PYTHON) tools/sfx_extract.py $(SP7001_PR2) HAMA2.SLD $@
# decompressed with the extraction repo's lzss module (its venv)
baserom/sp7001_tb%.bin: baserom/sp7001_tb%.sld tools/sld_decompress.py
	$(EXTRACT_DIR)/venv/bin/python tools/sld_decompress.py $< $@
baserom/sp7001_pr%.bin: baserom/sp7001_pr%.sld tools/sld_decompress.py
	$(EXTRACT_DIR)/venv/bin/python tools/sld_decompress.py $< $@

# Provenance of table 83 (notes/sp7001-build-diff.md): (1) the two table disks'
# payloads are byte-identical to the dump's two halves, plug-in included; (2) the
# disks' (identical) SMCKTB1/2.INF describe the directory image (0x3E0660 bytes, no
# plug-in) with the seg68-70 markers reading '83' -- they match exactly that, and the
# dump as shipped ('80') does NOT match (the checksum file predates the final payload).
.PHONY: verify-sp7001-floppy
verify-sp7001-floppy: baserom/sp7001_tb1_jkt1.bin baserom/sp7001_tb2_jktbl2.bin \
		baserom/sp7001_tb1_smck.inf baserom/sp7001_tb2_smck.inf \
		baserom/kn7000_table_sp7001.rom tools/smck_check.py
	@cmp -n 2097152 baserom/sp7001_tb1_jkt1.bin baserom/kn7000_table_sp7001.rom \
	    && echo "OK    disk 1 JKT1.SLD (decompressed) == table 83 [0x000000:0x200000]"
	@cmp -i 0:2097152 baserom/sp7001_tb2_jktbl2.bin baserom/kn7000_table_sp7001.rom \
	    && echo "OK    disk 2 JKTBL2.SLD (decompressed) == table 83 [0x200000:0x400000], plug-in included"
	@cmp baserom/sp7001_tb1_smck.inf baserom/sp7001_tb2_smck.inf \
	    && echo "OK    SMCKTB1.INF == SMCKTB2.INF (both describe the whole image)"
	@$(PYTHON) tools/smck_check.py baserom/kn7000_table_sp7001.rom baserom/sp7001_tb2_smck.inf \
	    --length 0x3E0660 --patch 0x3B7508:83 --patch 0x3B750C:83 --patch 0x3B7510:83 --expect match
	@$(PYTHON) tools/smck_check.py baserom/kn7000_table_sp7001.rom baserom/sp7001_tb2_smck.inf \
	    --length 0x3E0660 --expect mismatch

# The program update's two disks reconstruct program 942 the same way; its shipped
# SMCKPR*.INF predates the build and matches none of the images we hold, so there
# is nothing to patch it back to -- just the byte-identity.
.PHONY: verify-sp7001-progdisks
verify-sp7001-progdisks: baserom/sp7001_pr1_hama1.bin baserom/sp7001_pr2_hama2.bin \
		baserom/kn7000_program_sp7001.rom
	@cat baserom/sp7001_pr1_hama1.bin baserom/sp7001_pr2_hama2.bin > baserom/sp7001_prog_disks.bin
	@cmp -n 4164571 baserom/sp7001_prog_disks.bin baserom/kn7000_program_sp7001.rom \
	    && echo "OK    HAMA1.SLD + HAMA2.SLD (decompressed) == program 942 [0:0x3F8BDB]"

# ---- SP7001 symbols: PORTED from build 941/84, not re-derived ---------------
# tools/port_symbols.py translates every recovered name through the exact
# 941->942 / 84->83 offset maps (tools/offset_map.py) and cross-checks the
# 2302 reflection names against 942's own tables. The plug-in blob in table
# flash carries its own MILK reflection tables (35 KSS functions). Code ranges:
# 941's region bounds 0x186000 / 0x3B8000 mapped to 942 (0x1864F4 / 0x3B97B4).
SP7001_REFS := baserom/kn7000_program_sp7001.rom baserom/kn7000_table_sp7001.rom
SP7001_PORT := $(PYTHON) tools/port_symbols.py \
    baserom/kn7000_program.rom baserom/kn7000_program_sp7001.rom \
    baserom/kn7000_table.rom   baserom/kn7000_table_sp7001.rom
SP7001_PLUGIN := 0x3E8000:0x3FB5A0
# library image in program-flash 942 (941's 0x3B8FD1 through the offset map;
# tools/port_symbols.py prints it)
SP7001_LIB_FILE := 0x3BA785

# Build 941 names carried BACK from 942's plug-in export table (the functions
# they name exist in 941 too). Needs both builds' baserom; the committed
# kn7000_exports_from_942.sym is the result, so the default build doesn't.
# The library's micro-ITRON entry stubs are near-identical byte runs the offset map can
# misalign, so tools/itron_stubs.py then re-places each exported kernel name on the 941 stub
# that enters the same service routine (needs unidasm, $UNIDASM).
.PHONY: exports-941
exports-941: $(REFS) $(SP7001_REFS)
	@mkdir -p $(SYMOUT)
	$(PYTHON) tools/port_symbols.py baserom/kn7000_program_sp7001.rom baserom/kn7000_program.rom \
	    baserom/kn7000_table_sp7001.rom baserom/kn7000_table.rom \
	    kn7000_sp7001_exports.sym $(SYMOUT)/kn7000_exports_from_942.sym --old-lib-base $(SP7001_LIB_FILE) \
	    --title "KN7000 build 941: names from the SP7001 (build 942) plug-in export table, ported back"
	$(PYTHON) tools/itron_stubs.py baserom/kn7000_program_sp7001.rom $(SP7001_LIB_FILE) \
	    baserom/kn7000_program.rom 0x3B8FD1 kn7000_sp7001_exports.sym $(SYMOUT)/kn7000_exports_from_942.sym --fix

.PHONY: symbols-sp7001 program-src-sp7001
# (explicit only: see `symbols` above; it reads the committed kn7000.sym,
# kn7000_manual.sym and kn7000_sp7001_new.sym and writes under $(SYMOUT))
symbols-sp7001: $(REFS) $(SP7001_REFS)
	@mkdir -p $(SYMOUT)/src/sp7001
	$(SP7001_PORT) kn7000.sym $(SYMOUT)/kn7000_sp7001.sym --inc $(SYMOUT)/src/sp7001/symbols.inc \
	    --title "KN7000 SP7001 (program 942 / table 83) symbols" \
	    --check-recovered 0x80:0x1864F4 0x3B97B4:0x3F8BDB
	$(SP7001_PORT) kn7000_manual.sym $(SYMOUT)/kn7000_sp7001_manual.sym \
	    --title "KN7000 SP7001 manual symbol supplement"
	LIB_FILE_BASE=$(SP7001_LIB_FILE) UNIDASM=$(UNIDASM) $(PYTHON) tools/sp7001_exports.py \
	    baserom/kn7000_program_sp7001.rom $(SYMOUT)/kn7000_sp7001_exports.sym \
	    kn7000_sp7001.sym kn7000_sp7001_manual.sym kn7000_sp7001_new.sym
	$(PYTHON) tools/gen_symbols.py baserom/kn7000_table_sp7001.rom --program-base 0x48000000 \
	    --code-range $(SP7001_PLUGIN) --no-manual \
	    --title "KN7000 SP7001 table-flash XAPR plug-in: names from its own MILK reflection tables" \
	    --sym $(SYMOUT)/kn7000_sp7001_table.sym --inc $(SYMOUT)/src/sp7001/table_symbols.inc

# Regenerate src/sp7001/program.s from build 942 by porting build 941's split,
# conversions and notes (needs unidasm). The committed file is the result.
# Regenerate src/sp7001/table.s: the 84-segment directory image (each segment
# compared against build 84) plus the XAPR plug-in appended after it, whose code
# is emitted as real MN10300 assembly (needs unidasm). The committed file is the
# result.
SP7001_PLUGIN_CODE := 0x3E803C:0x3EF6C5
SP7001_TABLE_SYMS  := kn7000_sp7001_table.sym kn7000_sp7001_table_manual.sym \
                      kn7000_sp7001.sym kn7000_sp7001_manual.sym kn7000_sp7001_new.sym \
                      kn7000_sp7001_exports.sym
# Regenerate src/sp7001/baseext.s: BASEEXT.XAP as linked for 0x5029B000 (needs
# unidasm). Routines byte-identical to named program-942 routines take their names.
.PHONY: xap-src-sp7001
xap-src-sp7001: tools/gen_xap_s.py tools/gen_table_s.py tools/gen_program_s.py \
		kn7000_sp7001_baseext.sym kn7000_sp7001.sym kn7000_sp7001_manual.sym \
		kn7000_sp7001_exports.sym kn7000_sp7001_new.sym \
		baserom/sp7001_baseext.xap baserom/kn7000_program_sp7001.rom
	UNIDASM=$(UNIDASM) $(PYTHON) tools/gen_xap_s.py --xap baserom/sp7001_baseext.xap \
	    --out src/sp7001/baseext.s --base 0x5029B000 --code 0x0:0x1321E --typed-gaps \
	    --title 'SP7001 BASEEXT.XAP (Key Soft Service base extension) - byte-exact.' \
	    --sym kn7000_sp7001_baseext.sym \
	    --fw-rom baserom/kn7000_program_sp7001.rom --fw-r1-end 0x1864F4 --fw-lib-file $(SP7001_LIB_FILE) \
	    --fw-sym kn7000_sp7001.sym kn7000_sp7001_manual.sym kn7000_sp7001_exports.sym kn7000_sp7001_new.sym

# The plug-in's data (its MILK GUI, strings, reflection tables, initialised RAM) is typed by
# tools/gen_data_s.py --profile sp7001plugin into src/sp7001/plugin/data/, which table.s
# includes; it reads table.s's plug-in code and build/kn7000_table_sp7001.labels, and
# table-src-sp7001 reads its labels.sym back (data operands, code the data points at), so
# plugin-src runs the two until neither changes.
.PHONY: data-src-sp7001plugin plugin-src
data-src-sp7001plugin: tools/gen_data_s.py tools/milk_model.py build/kn7000_table_sp7001.rom
	$(PYTHON) tools/gen_data_s.py --profile sp7001plugin
plugin-src:
	@test -f build/kn7000_table_sp7001.labels || $(MAKE) --no-print-directory build/kn7000_table_sp7001.rom
	for i in 1 2; do \
	    $(PYTHON) tools/gen_data_s.py --profile sp7001plugin | sed -n 1p && \
	    $(MAKE) --no-print-directory table-src-sp7001 && \
	    $(MAKE) --no-print-directory build/kn7000_table_sp7001.rom || exit 1; done

.PHONY: table-src-sp7001
table-src-sp7001: tools/gen_table_s.py tools/table_segments.py tools/gen_program_s.py tools/gen_symbols.py \
		$(SP7001_TABLE_SYMS) baserom/kn7000_table.rom baserom/kn7000_table_sp7001.rom
	UNIDASM=$(UNIDASM) $(PYTHON) tools/gen_table_s.py --rom baserom/kn7000_table_sp7001.rom \
	    --out src/sp7001/table.s --jpg-dir src/table \
	    --title 'KN7000 SP7001 "Table" flash image (build 83) - byte-exact.' \
	    --compare baserom/kn7000_table.rom --compare-label "build 84" \
	    --plugin $(SP7001_PLUGIN) --plugin-code $(SP7001_PLUGIN_CODE) \
	    --plugin-data src/sp7001/plugin/data --sym $(SP7001_TABLE_SYMS)

program-src-sp7001: tools/gen_program_s.py tools/mn10300_asm.py tools/port_symbols.py \
		kn7000_sp7001.sym kn7000_sp7001_manual.sym kn7000_sp7001_new.sym \
		kn7000_sp7001_exports.sym $(wildcard annotations/*.ann) $(REFS) $(SP7001_REFS)
	UNIDASM=$(UNIDASM) $(PYTHON) tools/gen_program_s.py --profile sp7001

verify-sp7001: $(SP7001_TARGETS)
	@ok=1; \
	for name in kn7000_program_sp7001.rom kn7000_table_sp7001.rom sp7001_baseext.xap; do \
	  if cmp -s "build/$$name" "baserom/$$name"; then \
	    echo "OK    $$name is 100% byte-identical to the SP7001 dump"; \
	  else \
	    echo "FAIL  $$name differs from the SP7001 dump:"; \
	    cmp "build/$$name" "baserom/$$name" || true; \
	    ok=0; \
	  fi; \
	done; \
	[ $$ok -eq 1 ] || { echo; echo "SP7001 byte-match FAILED"; exit 1; }
	@echo; echo "SP7001 images reproduced byte-for-byte."

# ---- Style Convert Disk converters (.CNV) ----------------------------------
# The loadable MN10300 programs behind DISK MENU > STYLE CONVERT
# (notes/style-converter.md), from the two Style Convert Disks of MAME's floppy
# softlists: scd7000 (hash/kn7000_flop.xml) and scd6000 (hash/kn6000_flop.xml).
# Five of the six files are identical on both disks; TECHNICS.CNV is relinked, so
# there are seven sources in src/cnv/, fully disassembled (no .incbin) by
# tools/gen_cnv_s.py. The images are checked against the softlists' SHA-1, which
# are those of the 2026-10-18 rebuild in the instruments' own disk layout (the
# older images in ../../technics_romsets/kn*_flop/ hold the same files).
SOFTLIST_DIR ?= ../../technics_romsets/floppy-rebuild-2026-10-18/roms
SCD7000_SHA1 := ae04748349bc8a8c728c285a714ec94477796c88
SCD6000_SHA1 := c2c284e38b59bcbc3ac6d6aead515881bbc1d12e
CNV         := gem_ws2 gem_wx2 korg roland solton technics technics_kn6000
CNV_REFS    := $(CNV:%=baserom/cnv/%.cnv)
CNV_TARGETS := $(CNV:%=build/cnv/%.cnv)

.PHONY: build-cnv verify-cnv cnv-src
baserom/scd7000.img baserom/scd6000.img: baserom/%.img:
	@mkdir -p baserom
	unzip -p "$(SOFTLIST_DIR)/$(if $(findstring 7000,$*),kn7000_flop,kn6000_flop)/$*.zip" $*.img > $@.tmp
	echo "$(if $(findstring 7000,$*),$(SCD7000_SHA1),$(SCD6000_SHA1))  $@.tmp" | sha1sum --quiet -c
	mv $@.tmp $@

baserom/cnv/technics_kn6000.cnv: baserom/scd6000.img tools/fat12_extract.py
	@mkdir -p baserom/cnv
	$(PYTHON) tools/fat12_extract.py $< TECHNICS.CNV $@
baserom/cnv/%.cnv: baserom/scd7000.img tools/fat12_extract.py
	@mkdir -p baserom/cnv
	$(PYTHON) tools/fat12_extract.py $< $$(echo $* | tr a-z A-Z).CNV $@

build/cnv/%.cnv: src/cnv/%.s tools/kn7asm.py tools/mn10300_asm.py
	@mkdir -p build/cnv
	$(ASM) $< -I . -o $@

build-cnv: $(CNV_TARGETS)

verify-cnv: $(CNV_TARGETS) $(CNV_REFS)
	@ok=1; \
	for n in $(CNV); do \
	  if cmp -s "build/cnv/$$n.cnv" "baserom/cnv/$$n.cnv"; then \
	    echo "OK    src/cnv/$$n.s rebuilds $$n.cnv byte-for-byte"; \
	  else \
	    echo "FAIL  build/cnv/$$n.cnv differs from the disk's:"; \
	    cmp "build/cnv/$$n.cnv" "baserom/cnv/$$n.cnv" || true; ok=0; \
	  fi; \
	done; \
	[ $$ok -eq 1 ] || { echo; echo "Style converter byte-match FAILED"; exit 1; }
	@echo; echo "All 7 Style Convert Disk converters reproduced byte-for-byte."

# Regenerate src/cnv/*.s (needs unidasm and PROGRAM 941, whose named routines name
# the converters' copies of them). The committed files are the result.
CNV_SRC_SPEC = GEM_WS2=baserom/cnv/gem_ws2.cnv:"$(CNV_SCD7) GEM_WS2.CNV" \
	GEM_WX2=baserom/cnv/gem_wx2.cnv:"$(CNV_SCD7) GEM_WX2.CNV" \
	KORG=baserom/cnv/korg.cnv:"$(CNV_SCD7) KORG.CNV" \
	ROLAND=baserom/cnv/roland.cnv:"$(CNV_SCD7) ROLAND.CNV" \
	SOLTON=baserom/cnv/solton.cnv:"$(CNV_SCD7) SOLTON.CNV" \
	TECHNICS=baserom/cnv/technics.cnv:"$(CNV_SCD7) TECHNICS.CNV" \
	TECHNICS_KN6000=baserom/cnv/technics_kn6000.cnv:"$(CNV_SCD6) TECHNICS.CNV"
CNV_SCD7 := MAME softlist kn7000_flop, scd7000 (Style Convert Disk, Technics 1999), scd7000.img:
CNV_SCD6 := MAME softlist kn6000_flop, scd6000 (Style Convert Disk, Technics 1999), scd6000.img:
cnv-src: tools/gen_cnv_s.py tools/gen_xap_s.py cnv_manual.sym $(CNV_REFS) \
		baserom/kn7000_program.rom kn7000.sym kn7000_manual.sym kn7000_exports_from_942.sym
	UNIDASM=$(UNIDASM) $(PYTHON) tools/gen_cnv_s.py $(CNV_SRC_SPEC) --outdir src/cnv \
	    --names cnv_manual.sym \
	    --fw-rom baserom/kn7000_program.rom --fw-r1-end 0x186000 --fw-lib-file 0x3B8FD1 \
	    --fw-sym kn7000.sym kn7000_manual.sym kn7000_exports_from_942.sym

# ---- IC18's first 64 KB: the boot ROM ---------------------------------------
# The CPU starts at 0x40000000, where IC18 (the 4 MB rhythm ROM C3CBND000046)
# answers; its first 64 KB is MN10300 code: reset, the flash-update system menu,
# and the jump to the program flash. src/ic18/boot.s is all of it, fully
# disassembled (tools/gen_ic18_s.py), and carries every byte, so it builds
# without the reference. The reference is cut from the chip image in the private
# romset (a read of Felipe's own instrument, pass 4 of the dumper), which is
# checked first. See notes/ic18-boot-rom.md.
IC18_ROM       ?= $(ROMSET_DIR)/c3cbnd000046.ic18
IC18_SHA1      := 2dc71f5082063cd6b21e4ed16acd67e9d326a79f
IC18_BOOT_SHA1 := 00db930227efcac3b329edbb210db5ec26dfa25e

.PHONY: verify-ic18 ic18-src
baserom/kn7000_ic18_boot.bin:
	@mkdir -p baserom
	echo "$(IC18_SHA1)  $(IC18_ROM)" | sha1sum --quiet -c
	head -c 65536 "$(IC18_ROM)" > $@.tmp
	echo "$(IC18_BOOT_SHA1)  $@.tmp" | sha1sum --quiet -c
	mv $@.tmp $@

# the boot ROM's 8x16 font is the PNG sheet src/ic18/media/FontGlyphs8x16.png (lane media-files)
IC18_PNGS := $(wildcard src/ic18/media/*.png)
build/ic18_png/.stamp: $(IC18_PNGS) tools/table_png.py
	@mkdir -p build/ic18_png
	$(PYTHON) tools/table_png.py build --out-dir build/ic18_png --src-root src/ic18/media $(IC18_PNGS)
	@touch $@

build/kn7000_ic18_boot.bin: src/ic18/boot.s tools/kn7asm.py tools/mn10300_asm.py build/ic18_png/.stamp
	@mkdir -p build
	$(ASM) src/ic18/boot.s -I . -o $@

verify-ic18: build/kn7000_ic18_boot.bin baserom/kn7000_ic18_boot.bin
	@if [ "$$(sha1sum < $< | cut -d' ' -f1)" = "$(IC18_BOOT_SHA1)" ] && cmp -s $< baserom/kn7000_ic18_boot.bin; then \
	    echo "OK    kn7000_ic18_boot.bin is 100% byte-identical to IC18's first 64 KB (SHA-1 $(IC18_BOOT_SHA1))"; \
	 else echo "FAIL  kn7000_ic18_boot.bin differs from IC18's first 64 KB:"; \
	    cmp $< baserom/kn7000_ic18_boot.bin || true; exit 1; fi

# Regenerate src/ic18/boot.s (needs unidasm, and PROGRAM 941 for the names of the
# routines this ROM shares with the firmware). The committed file is the result.
ic18-src: tools/gen_ic18_s.py tools/gen_xap_s.py kn7000_ic18.sym baserom/kn7000_ic18_boot.bin \
		baserom/kn7000_program.rom kn7000.sym kn7000_manual.sym kn7000_exports_from_942.sym
	UNIDASM=$(UNIDASM) $(PYTHON) tools/gen_ic18_s.py --rom baserom/kn7000_ic18_boot.bin \
	    --out src/ic18/boot.s --names kn7000_ic18.sym \
	    --fw-rom baserom/kn7000_program.rom --fw-r1-end 0x186000 --fw-lib-file 0x3B8FD1 \
	    --fw-sym kn7000.sym kn7000_manual.sym kn7000_exports_from_942.sym

# ---- All of IC18: the boot ROM and the rhythm data -----------------------------
# src/ic18/ic18.s is boot.s (above) followed by rhythm.s, the "Technics Rhythms"
# style resource from 0x10000 to the end of the chip, typed record by record and
# event by event (tools/gen_ic18_rhythm_s.py; one file per style under
# src/ic18/styles/, the leftovers in src/ic18/old_build.s). It carries every byte,
# so it builds without the reference; the whole chip image is copied here, its
# SHA-1 checked, only to compare. See notes/ic18-rhythm-rom.md.
IC18_SRC := $(shell find src/ic18 -name '*.s')
.PHONY: verify-ic18-full ic18-rhythm-src
baserom/kn7000_ic18.rom:
	@mkdir -p baserom
	echo "$(IC18_SHA1)  $(IC18_ROM)" | sha1sum --quiet -c
	cp "$(IC18_ROM)" $@.tmp
	echo "$(IC18_SHA1)  $@.tmp" | sha1sum --quiet -c
	mv $@.tmp $@

build/kn7000_ic18.bin: $(IC18_SRC) tools/kn7asm.py tools/mn10300_asm.py build/ic18_png/.stamp
	@mkdir -p build
	$(ASM) src/ic18/ic18.s -I . -o $@ --labels build/kn7000_ic18.labels

verify-ic18-full: build/kn7000_ic18.bin baserom/kn7000_ic18.rom
	@if [ "$$(sha1sum < $< | cut -d' ' -f1)" = "$(IC18_SHA1)" ] && cmp -s $< baserom/kn7000_ic18.rom; then \
	    echo "OK    kn7000_ic18.bin is 100% byte-identical to all of IC18 (SHA-1 $(IC18_SHA1))"; \
	 else echo "FAIL  kn7000_ic18.bin differs from IC18:"; \
	    cmp $< baserom/kn7000_ic18.rom || true; exit 1; fi

# Regenerate src/ic18/rhythm.s (needs program 941 and table 84 for the rhythm
# groups and the table-ROM style names). The committed file is the result.
ic18-rhythm-src: tools/gen_ic18_rhythm_s.py baserom/kn7000_ic18.rom baserom/kn7000_program.rom \
		baserom/kn7000_table.rom
	$(PYTHON) tools/gen_ic18_rhythm_s.py --rom baserom/kn7000_ic18.rom \
	    --program baserom/kn7000_program.rom --table baserom/kn7000_table.rom \
	    --out src/ic18/rhythm.s

# ---- Table build 80 (pairs with program 893, v1.3) -------------------------
# The reference is the read of Felipe's own instrument: the two EPROM halves in
# the private romset, de-interleaved like SP7001's. src/b80/table.s builds it
# from table 83's image (build/kn7000_table_sp7001.rom, from src/sp7001/table.s)
# with build 80's one different byte and no plug-in. See src/b80/table.s.
TABLE80_SHA1 := 2e50a40b81c0caafd60d3487c13a3f988629d95f

.PHONY: verify-table80
baserom/kn7000_table_b80.rom: tools/rom_from_eproms.py
	@mkdir -p baserom
	$(PYTHON) tools/rom_from_eproms.py \
	    "$(ROMSET_DIR)/kn7000_table_even_b80.ic17" \
	    "$(ROMSET_DIR)/kn7000_table_odd_b80.ic16" $@.tmp
	echo "$(TABLE80_SHA1)  $@.tmp" | sha1sum --quiet -c
	mv $@.tmp $@

build/kn7000_table_b80.rom: src/b80/table.s build/kn7000_table_sp7001.rom tools/kn7asm.py
	@mkdir -p build
	$(ASM) src/b80/table.s -I . -o $@

verify-table80: build/kn7000_table_b80.rom baserom/kn7000_table_b80.rom
	@if cmp -s build/kn7000_table_b80.rom baserom/kn7000_table_b80.rom; then \
	    echo "OK    kn7000_table_b80.rom is 100% byte-identical to table build 80 (SHA-1 $(TABLE80_SHA1))"; \
	 else echo "FAIL  kn7000_table_b80.rom differs from table build 80:"; \
	    cmp build/kn7000_table_b80.rom baserom/kn7000_table_b80.rom || true; exit 1; fi

# ---- Older program builds, ported from 941 (935 = v1.5, 893 = v1.3) ---------
# Each is a byte-exact target with real source, made like SP7001's program 942:
# tools/gen_program_s.py --profile b<N> ports 941's names, function split, caps,
# data islands and notes through the exact 941->N offset map, dropping (and
# counting) what has no 1:1 counterpart; tools/port_names_by_code.py then names
# the routines the map cannot place where they are the same code as a named 941
# routine. The reference is the de-interleaved EPROM pair in the private romset,
# checked against the SHA-1 recorded here. Per build:
#   make verify-<N>        build src/b<N>/program.s and compare it with the reference
#   make symbols-<N>       port kn7000.sym / _manual / _exports_from_942 (needs 941's baserom)
#   make program-src-<N>   regenerate src/b<N>/ (needs unidasm and 941's baserom)
#   make ported-names-<N>  carry names by code (needs unidasm; then program-src-<N> again)
#   make check-names-<N>   do the ported names sit on the same routine as in 941?
# PORT_MIN_RUN: the shortest 1:1 run of the offset map a ported program address
# may sit on (tools/port_symbols.py --min-run; MIN_RUN in gen_program_s.py).
PORT_MIN_RUN := 16
COMMA        := ,
B941_CODE    := 0x80:0x186000 0x3b8fd1:0x3f6f01:0x4c000000
B935_SHA1    := 5690195daa4c098069c0d84b4933bd1325f98269
B935_EPROMS  := kn7000_program_even_v1.5_b935.ic17 kn7000_program_odd_v1.5_b935.ic16
B935_TABLE   := baserom/kn7000_table.rom
# code region 1 ends at 0x18595C (gen_program_s.py PORTED_BUILDS["b935"]); the
# library image is file 0x3B8F6D..0x3F6E9D, linked for 0x4C000000
B935_CODE    := 0x80:0x18595c 0x3b8f6d:0x3f6e9d:0x4c000000
# where gen_symbols.py looks for the reflection tables' procedures: region 1 and
# code region 2 (941's 0x3B8000..0x3F6F01 through the map), as for SP7001
B935_RECOVER := 0x80:0x18595C 0x3B7F9C:0x3F6E9D
# 893 (v1.3) is the program flash of Felipe's own instrument; the romset's two halves
# are the dumper's pass-1 reads (real_dump_v1.3_b893/pass1-run{1,2}/PRG{EVEN,ODD}.BIN,
# identical in both runs). It pairs with table 80 (verify-table80 above).
B893_SHA1    := 13e0b29181b7bbee671dba70d707e0f55161a15c
B893_EPROMS  := kn7000_program_even_v1.3_b893.ic17 kn7000_program_odd_v1.3_b893.ic16
B893_TABLE   := baserom/kn7000_table_b80.rom
B893_CODE    := 0x80:0x1846a0 0x3b76b1:0x3f55cf:0x4c000000
B893_RECOVER := 0x80:0x1846A0 0x3B66E0:0x3F55CF

# $(1) = build number
define PORTED_BUILD
.PHONY: verify-$(1) symbols-$(1) program-src-$(1) ported-names-$(1) check-names-$(1)
baserom/kn7000_program_b$(1).rom: tools/rom_from_eproms.py
	@mkdir -p baserom
	$$(PYTHON) tools/rom_from_eproms.py $$(B$(1)_EPROMS:%="$$(ROMSET_DIR)/%") $$@.tmp
	echo "$$(B$(1)_SHA1)  $$@.tmp" | sha1sum --quiet -c
	mv $$@.tmp $$@

build/kn7000_program_b$(1).rom: src/b$(1)/program.s $$(wildcard src/b$(1)/program/*.s) \
		$$(wildcard src/b$(1)/program/data/*) src/constants.inc src/b$(1)/symbols.inc \
		tools/kn7asm.py tools/mn10300_asm.py baserom/kn7000_program_b$(1).rom build/bitmaps/b$(1)/.stamp
	@mkdir -p build
	$$(ASM) src/b$(1)/program.s -I . -o $$@ --labels build/kn7000_program_b$(1).labels

verify-$(1): build/kn7000_program_b$(1).rom baserom/kn7000_program_b$(1).rom
	@if cmp -s build/kn7000_program_b$(1).rom baserom/kn7000_program_b$(1).rom; then \
	    echo "OK    kn7000_program_b$(1).rom is 100% byte-identical to program build $(1) (SHA-1 $$(B$(1)_SHA1))"; \
	 else echo "FAIL  kn7000_program_b$(1).rom differs from program build $(1):"; \
	    cmp build/kn7000_program_b$(1).rom baserom/kn7000_program_b$(1).rom || true; exit 1; fi

B$(1)_PORT = $$(PYTHON) tools/port_symbols.py baserom/kn7000_program.rom baserom/kn7000_program_b$(1).rom \
    baserom/kn7000_table.rom $$(B$(1)_TABLE) --min-run $$(PORT_MIN_RUN) --cache-dir build/offset-maps
# (explicit only, as `symbols`: no rule has the committed files as its target, so
# verify-<N> never re-ports symbols)
symbols-$(1): $$(REFS) $$(B$(1)_TABLE) baserom/kn7000_program_b$(1).rom
	@mkdir -p $$(SYMOUT)/src/b$(1)
	$$(B$(1)_PORT) kn7000.sym $$(SYMOUT)/kn7000_b$(1).sym --inc $$(SYMOUT)/src/b$(1)/symbols.inc \
	    --title "KN7000 program $(1) symbols" \
	    --check-recovered $$(B$(1)_RECOVER)
	$$(B$(1)_PORT) kn7000_manual.sym $$(SYMOUT)/kn7000_b$(1)_manual.sym \
	    --title "KN7000 program $(1) manual symbol supplement"
	$$(B$(1)_PORT) kn7000_exports_from_942.sym $$(SYMOUT)/kn7000_b$(1)_exports.sym \
	    --title "KN7000 program $(1): the SP7001 plug-in export names (ported 942 -> 941 -> $(1))"

program-src-$(1): tools/gen_program_s.py tools/mn10300_asm.py tools/port_symbols.py tools/offset_map.py \
		kn7000_b$(1).sym kn7000_b$(1)_manual.sym kn7000_b$(1)_exports.sym $$(wildcard kn7000_b$(1)_bycode.sym) \
		$$(wildcard annotations/*.ann) $$(REFS) $$(B$(1)_TABLE) baserom/kn7000_program_b$(1).rom
	UNIDASM=$$(UNIDASM) $$(PYTHON) tools/gen_program_s.py --profile b$(1)

ported-names-$(1): tools/port_names_by_code.py tools/gen_image_s.py src/b$(1)/program.s \
		baserom/kn7000_program.rom baserom/kn7000_program_b$(1).rom
	$$(PYTHON) tools/port_names_by_code.py --a-rom baserom/kn7000_program.rom \
	    $$(B941_CODE:%=--a-code %) --a-sym kn7000_manual.sym kn7000_exports_from_942.sym kn7000.sym \
	    --b-rom baserom/kn7000_program_b$(1).rom --b-base 0x48400000 $$(B$(1)_CODE:%=--b-code %) \
	    --b-sym kn7000_b$(1).sym kn7000_b$(1)_manual.sym kn7000_b$(1)_exports.sym \
	    --b-src src/b$(1)/program.s $$(wildcard src/b$(1)/program/*.s) \
	    --out kn7000_b$(1)_bycode.sym --unidasm $$(UNIDASM) \
	    --title "KN7000 program $(1): names carried from program 941 by code (routines the offset map cannot place)"

check-names-$(1): tools/check_ported_names.py baserom/kn7000_program.rom baserom/kn7000_program_b$(1).rom
	$$(PYTHON) tools/check_ported_names.py --b-rom baserom/kn7000_program_b$(1).rom \
	    $$(B941_CODE:%=--a-code %) $$(B$(1)_CODE:%=--b-code %) --unidasm $$(UNIDASM) \
	    --pair kn7000.sym:kn7000_b$(1).sym --pair kn7000_manual.sym:kn7000_b$(1)_manual.sym \
	    --pair kn7000_exports_from_942.sym:kn7000_b$(1)_exports.sym \
	    $$(if $$(wildcard kn7000_b$(1)_bycode.sym),\
	      --pair kn7000.sym$$(COMMA)kn7000_manual.sym$$(COMMA)kn7000_exports_from_942.sym:kn7000_b$(1)_bycode.sym)
endef
$(eval $(call PORTED_BUILD,935))
$(eval $(call PORTED_BUILD,893))

clean:
	rm -rf build

distclean: clean
	rm -f baserom/*.rom disasm/program.asm

# ---- the four wave ROMs (IC203/IC204 MAIN TG, IC207/IC208 SUB TG) ------------
# Each tone generator's Y and X chips are one stream of 16-bit words, word i of Y
# then word i of X. src/wave/main.s and src/wave/sub.s describe the two streams:
# per 2 MiB page a directory, its parameter records (typed .word fields) and the
# recordings, one labelled .incbin_range each of the reference stream.  The build
# assembles a stream and tools/wave_pair.py splits it into the two chips, which
# must have the SHA-1 of the instrument's (a read of Felipe's own KN7000, pass 3
# of the ROM dumper). The reference streams (git-ignored) are joined from the
# chip images in the private romset, checked first. See notes/wave-roms-2026-10-29.md.
WAVE_ROMSET ?= $(HOME)/compartilhado/technics_romsets/kn7000
WAVE_IC203  := c3cbqd000002.ic203
WAVE_IC204  := c3cbqd000001.ic204
WAVE_IC207  := c3cbqd000004.ic207
WAVE_IC208  := c3cbqd000003.ic208
WAVE_IC203_SHA1 := f2d01ffd020c39a3f5b9d6c3275b1855c5a3d1a6
WAVE_IC204_SHA1 := f6da330c14cd3bdfc7c19092bd20d188e3ef0600
WAVE_IC207_SHA1 := 729bb2dd6aebd2932de6960363a554b89ffc171a
WAVE_IC208_SHA1 := fb48cbc5334f5221ea882d63a58a22f9466e78c7
WAVE_MAIN_SHA1  := 6c8adb2d329bb12436602cbcb6e71dfb5ae2c569
WAVE_SUB_SHA1   := e9ee2b1c4e2bdf8d11036f37f2e7d26619c9bac9
# per stream: its Y and X chips
WAVE_main_Y := $(WAVE_IC203)
WAVE_main_X := $(WAVE_IC204)
WAVE_sub_Y  := $(WAVE_IC207)
WAVE_sub_X  := $(WAVE_IC208)
WAVE_main_Y_SHA1 := $(WAVE_IC203_SHA1)
WAVE_main_X_SHA1 := $(WAVE_IC204_SHA1)
WAVE_sub_Y_SHA1  := $(WAVE_IC207_SHA1)
WAVE_sub_X_SHA1  := $(WAVE_IC208_SHA1)
WAVE_main_SHA1   := $(WAVE_MAIN_SHA1)
WAVE_sub_SHA1    := $(WAVE_SUB_SHA1)

.PHONY: verify-wave wave-src
baserom/kn7000_wave_main.bin baserom/kn7000_wave_sub.bin: baserom/kn7000_wave_%.bin: tools/wave_pair.py
	@mkdir -p baserom
	echo "$(WAVE_$*_Y_SHA1)  $(WAVE_ROMSET)/$(WAVE_$*_Y)" | sha1sum --quiet -c
	echo "$(WAVE_$*_X_SHA1)  $(WAVE_ROMSET)/$(WAVE_$*_X)" | sha1sum --quiet -c
	$(PYTHON) tools/wave_pair.py join "$(WAVE_ROMSET)/$(WAVE_$*_Y)" "$(WAVE_ROMSET)/$(WAVE_$*_X)" $@.tmp
	echo "$(WAVE_$*_SHA1)  $@.tmp" | sha1sum --quiet -c
	mv $@.tmp $@

# The recordings are WAV files, wav/main/ and wav/sub/, committed (the owner, 2026-10-31: "Images
# and wav files must be commited and the conversion must happen as a build step").
# ../scripts/build/pcm_wav.py turns them into the raw items build/wav_pcm/<tg>/<label>.pcm the
# sources `.incbin`, using the manifests src/wave/<tg>_wav.tsv (written by tools/gen_wave_s.py),
# and reads no reference stream to do it.  See ../notes/media-files-2026-10-30/README.md and
# ../notes/media-build-2026-10-31/README.md.
PCM_WAV := $(PYTHON) ../scripts/build/pcm_wav.py
define WAVE_WAV_RULES
# every WAV the manifest names (column 6), so a missing one stops make instead of being skipped
WAVE_WAVS_$(1) := $$(addprefix wav/$(1)/,$$(shell tail -n +2 src/wave/$(1)_wav.tsv | cut -f6))
build/wav_pcm/$(1).done: $$(WAVE_WAVS_$(1)) src/wave/$(1)_wav.tsv ../scripts/build/pcm_wav.py
	$$(PCM_WAV) build src/wave/$(1)_wav.tsv wav/$(1) build/wav_pcm/$(1)
	@touch $$@
endef
$(foreach t,main sub,$(eval $(call WAVE_WAV_RULES,$(t))))

.PHONY: wave-wav
# MAINTENANCE, not a build step: write the WAVs that are missing from the reference streams (an
# edited WAV is never overwritten).  The WAVs are committed; run this only to recover one.
wave-wav: baserom/kn7000_wave_main.bin baserom/kn7000_wave_sub.bin
	for t in main sub; do $(PCM_WAV) extract --missing src/wave/$${t}_wav.tsv baserom/kn7000_wave_$${t}.bin wav/$${t} || exit 1; done

build/kn7000_wave_%.bin: src/wave/%.s src/wave/wave_format.inc tools/kn7asm.py build/wav_pcm/%.done
	@mkdir -p build
	$(ASM) $< -I . -o $@

build/wave/main.done build/wave/sub.done: build/wave/%.done: build/kn7000_wave_%.bin tools/wave_pair.py
	@mkdir -p build/wave
	$(PYTHON) tools/wave_pair.py split $< build/wave/$(WAVE_$*_Y) build/wave/$(WAVE_$*_X)
	@touch $@

verify-wave: build/wave/main.done build/wave/sub.done
	@ok=1; \
	for c in "IC203 $(WAVE_IC203) $(WAVE_IC203_SHA1)" "IC204 $(WAVE_IC204) $(WAVE_IC204_SHA1)" \
	         "IC207 $(WAVE_IC207) $(WAVE_IC207_SHA1)" "IC208 $(WAVE_IC208) $(WAVE_IC208_SHA1)"; do \
	  set -- $$c; \
	  if [ "$$(sha1sum < build/wave/$$2 | cut -d' ' -f1)" = "$$3" ]; then \
	    echo "OK    build/wave/$$2 ($$1) is 100% byte-identical to the instrument's wave ROM (SHA-1 $$3)"; \
	  else echo "FAIL  build/wave/$$2 ($$1): SHA-1 is not $$3"; ok=0; fi; \
	done; \
	[ $$ok -eq 1 ] || { echo; echo "wave ROM byte-match FAILED"; exit 1; }

# Regenerate src/wave/main.s and src/wave/sub.s from the reference streams. The
# committed files are the result; the build does not need this.
wave-src: tools/gen_wave_s.py baserom/kn7000_wave_main.bin baserom/kn7000_wave_sub.bin
	$(PYTHON) tools/gen_wave_s.py main baserom/kn7000_wave_main.bin src/wave/main.s
	$(PYTHON) tools/gen_wave_s.py sub  baserom/kn7000_wave_sub.bin  src/wave/sub.s
# ---- the factory CUSTOM STYLE memory: IC21's bank at 0x96820000 -------------
# Nine factory sets, one .AST file each on the softlist floppies idd7000 (Initial
# Data Disk, 01CTMINI = the shipped set), custom1 and custom2 (eight more). The
# .AST is the 0x1E0000-byte bank, deflated (tools/ast_file.py); the reference
# images in baserom/customdata/ are inflated from the floppies and checked against
# the SHA-1 recorded here (= the images in the private romset). src/customdata/*.s
# are generated by tools/gen_customdata_s.py (make customdata-src); the bulk items
# in them are .incbin_range of these references. See notes/custom-data-ic21.md.
CUSTOMDATA      := 01ctmini 01custm1 02custm2 03custm3 04custm4 01custm5 02custm6 03custm7 04custm8
CD_DISK_01ctmini := idd7000
CD_DISK_01custm1 := custom1
CD_DISK_02custm2 := custom1
CD_DISK_03custm3 := custom1
CD_DISK_04custm4 := custom1
CD_DISK_01custm5 := custom2
CD_DISK_02custm6 := custom2
CD_DISK_03custm7 := custom2
CD_DISK_04custm8 := custom2
CD_SHA1_01ctmini := 67b2a0fe8154c4d15557399a86bf0d0b49813ced
CD_SHA1_01custm1 := 4cd5fe37871984a4b470b1a12b835c9bc41f37f5
CD_SHA1_02custm2 := 6c85b616a9acc3a7ecc1b49a70f138c0d9442086
CD_SHA1_03custm3 := d5722a1129134383bf643d20b4e0866c3089fc36
CD_SHA1_04custm4 := 25822a3ad726df49882cdd0066424600fb70ea14
CD_SHA1_01custm5 := 11d32c3d293a23a511a76297647758046cd8ccc9
CD_SHA1_02custm6 := 54f2bac0551a8d43dc1a87fe24a13c545169a326
CD_SHA1_03custm7 := e1bdfbbbe78353003af5ed01866be87d799523bb
CD_SHA1_04custm8 := f4722d93ff3f31c6d8c25f757968d796e4eb57ca
CD_REFS    := $(CUSTOMDATA:%=baserom/customdata/%.ic21)
CD_TARGETS := $(CUSTOMDATA:%=build/customdata/%.ic21)
.SECONDARY: $(CUSTOMDATA:%=baserom/customdata/%.ast)

.PHONY: verify-customdata customdata-src verify-customdata-ast
baserom/idd7000.img baserom/custom1.img baserom/custom2.img: baserom/%.img:
	@mkdir -p baserom
	unzip -p "$(SOFTLIST_DIR)/kn7000_flop/$*.zip" $*.img > $@.tmp
	mv $@.tmp $@

define CD_AST_RULE
baserom/customdata/$(1).ast: baserom/$(CD_DISK_$(1)).img tools/fat12_extract.py
	@mkdir -p baserom/customdata
	$$(PYTHON) tools/fat12_extract.py $$< $(shell echo $(1) | tr a-z A-Z).AST $$@
endef
$(foreach n,$(CUSTOMDATA),$(eval $(call CD_AST_RULE,$(n))))

baserom/customdata/%.ic21: baserom/customdata/%.ast tools/ast_file.py
	$(PYTHON) tools/ast_file.py inflate $< $@.tmp
	echo "$(CD_SHA1_$*)  $@.tmp" | sha1sum --quiet -c
	mv $@.tmp $@

define CD_BUILD_RULE
build/customdata/$(1).ic21: src/customdata/$(1).s $(wildcard src/customdata/$(1)/*.inc) src/customdata/customdata.inc src/include/panel_memory.inc src/include/voice_record.inc \
		tools/kn7asm.py baserom/customdata/$(1).ic21
	@mkdir -p build/customdata
	$$(ASM) $$< -I . -o $$@
endef
$(foreach n,$(CUSTOMDATA),$(eval $(call CD_BUILD_RULE,$(n))))

verify-customdata: $(CD_TARGETS) $(CD_REFS)
	@ok=1; \
	for n in $(CUSTOMDATA); do \
	  if cmp -s build/customdata/$$n.ic21 baserom/customdata/$$n.ic21; then \
	    echo "OK    src/customdata/$$n.s rebuilds $$n.ic21 byte-for-byte"; \
	  else echo "FAIL  build/customdata/$$n.ic21 differs:"; \
	    cmp build/customdata/$$n.ic21 baserom/customdata/$$n.ic21 || true; ok=0; fi; \
	done; \
	[ $$ok -eq 1 ] || { echo; echo "Custom-data byte-match FAILED"; exit 1; }
	@echo; echo "All 9 factory custom-style banks reproduced byte-for-byte."

# Rebuild each .AST file from its image with tools/zlib10_deflate.py, the port of the
# programs' zlib 1.0.4 (header tag and the 8 stack bytes taken from the floppy's file),
# and compare with the floppy's file. About 6 s an image; not part of the gate.
verify-customdata-ast: $(CD_REFS) tools/ast_file.py tools/zlib10_deflate.py
	@mkdir -p build/customdata
	@for n in $(CUSTOMDATA); do \
	  $(PYTHON) tools/ast_file.py deflate baserom/customdata/$$n.ic21 build/customdata/$$n.ast \
	    --like baserom/customdata/$$n.ast || exit 1; \
	done

# Regenerate src/customdata/*.s from the references. The committed files are the result.
customdata-src: tools/gen_customdata_s.py $(CD_REFS)
	$(foreach n,$(CUSTOMDATA),$(PYTHON) tools/gen_customdata_s.py --rom baserom/customdata/$(n).ic21 \
	    --corpus $(foreach m,$(CUSTOMDATA),$(m)=baserom/customdata/$(m).ic21) \
	    --ref baserom/customdata/$(n).ic21 --out src/customdata/$(n).s --model kn7000 \
	    --include src/customdata/customdata.inc \
	    --title 'Technics SX-KN7000 factory CUSTOM STYLE memory "$(n)" (IC21, bank 0x96820000) - byte-exact.' \
	    --title 'Reference: $(n).ic21, the 0x1E0000-byte bank inflated from $(shell echo $(n) | tr a-z A-Z).AST' \
	    --title 'of the MAME softlist kn7000_flop floppy $(CD_DISK_$(n)) (tools/ast_file.py).' && ) true

# ---- Felipe's own IC21: the whole 2 MB custom-data flash of his KN7000 -----
# The owner's decision (2026-10-31): "Yes, lets add IC21 as well." The reference is
# pass 1 of the ROM dumper on his instrument (PROGRAM 893, TABLE 80), 2026-10-19,
# read twice with identical results; it is private, so it is copied here, git-ignored
# and SHA-1 checked, like the other references. src/ic21own/ic21.s types the whole chip
# (CPU 0x96800000-0x969FFFFF): the USER MIDI SETTING image at 0x4000, the flash-test
# pattern at 0x6000, FAVORITES at 0x10000, HOME PAGE at 0x11000 and the CUSTOM STYLE
# bank at 0x20000 (src/ic21own/custom.s, made by tools/gen_customdata_s.py --base).
# See notes/ic21-own/README.md.
IC21_OWN      ?= $(HOME)/compartilhado/technics_roms/roms/kn7000/real_dump_v1.3_b893/pass1-run1/IC21.BIN
IC21_OWN_SHA1 := 33b988ec7f63e5fe3c8299f1db2e3b5955a71ff2
IC21_OWN_REF  := baserom/kn7000_ic21_own.bin
.PHONY: verify-ic21-own ic21-own-src ic21-own-probes
$(IC21_OWN_REF):
	@mkdir -p baserom
	echo "$(IC21_OWN_SHA1)  $(IC21_OWN)" | sha1sum --quiet -c
	cp "$(IC21_OWN)" $@.tmp
	echo "$(IC21_OWN_SHA1)  $@.tmp" | sha1sum --quiet -c
	mv $@.tmp $@

build/ic21own/kn7000_ic21_own.bin: src/ic21own/ic21.s $(wildcard src/ic21own/*.inc src/ic21own/custom/*.inc) \
		src/ic21own/custom.s src/include/user_settings.inc src/customdata/customdata.inc \
		src/include/panel_memory.inc src/include/voice_record.inc src/b893/program/data/media/Bmp_48743E5C.bmp \
		tools/kn7asm.py $(IC21_OWN_REF)
	@mkdir -p build/ic21own
	$(ASM) $< -I . -o $@

verify-ic21-own: build/ic21own/kn7000_ic21_own.bin $(IC21_OWN_REF)
	@if cmp -s $< $(IC21_OWN_REF); then \
	  echo "OK    src/ic21own/ic21.s rebuilds the 2 MB IC21 read byte-for-byte ($(IC21_OWN_SHA1))"; \
	else echo "FAIL  $< differs:"; cmp $< $(IC21_OWN_REF) || true; exit 1; fi

# Regenerate the typed sources from the reference. The committed files are the result;
# the corpus that types the CUSTOM bank's residue is the nine factory sets plus this bank.
ic21-own-src: tools/gen_ic21own_s.py tools/gen_customdata_s.py $(IC21_OWN_REF) $(CD_REFS)
	$(PYTHON) tools/gen_ic21own_s.py --rom $(IC21_OWN_REF) --ref $(IC21_OWN_REF) --out-dir src/ic21own
	$(PYTHON) tools/gen_customdata_s.py --rom $(IC21_OWN_REF) --base 0x20000 --part \
	    --corpus $(foreach m,$(CUSTOMDATA),$(m)=baserom/customdata/$(m).ic21) \
	    --ref $(IC21_OWN_REF) --out src/ic21own/custom.s --inc-dir src/ic21own/custom --model kn7000 \
	    --include src/customdata/customdata.inc \
	    --opaque-why "unknown-dump: residue of an earlier write that no typed record of the nine factory sets or of this bank holds (no 32-byte match at any offset) and that does not parse as events (probe residue_cover.py)" \
	    --title "Felipe's KN7000 IC21, the CUSTOM STYLE bank at chip 0x20000 (CPU 0x96820000); part of src/ic21own/ic21.s."

# The probes behind the figures in src/ic21own/ic21.s and notes/ic21-own/README.md.
ic21-own-probes: $(IC21_OWN_REF) $(CD_REFS) baserom/idd7000.img
	@for p in regions regions2 templates custom names_kn5000 name_fields marker name_origin ots_origin hp_parts section_map stream_rules; do \
	  echo "==== notes/ic21-own-probes/$$p.py"; $(PYTHON) -I notes/ic21-own-probes/$$p.py || exit 1; done
