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
EXTRACT_DIR ?= ../kn7000_extraction
DISKS_DIR   ?= ../KN7000

# SP7001 variant: its reference images come from the raw EPROM-half dumps in the
# (private) MAME romset, de-interleaved by tools/rom_from_eproms.py — not from
# the update disks. Override if the romset lives elsewhere.
ROMSET_DIR  ?= ../technics_romsets/kn7000

# MAME's unidasm, used only by `make disasm` to (re)generate the reference
# listings. Point this at your MAME build's unidasm binary.
UNIDASM     ?= ../mame-sony-video/unidasm

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
build/kn7000_program.rom: src/program.s src/symbols.inc tools/kn7asm.py baserom/kn7000_program.rom
	@mkdir -p build
	$(ASM) src/program.s -I . -o $@

# ---- recover symbols from the firmware's MILK-toolkit reflection tables -----
# Names 444 functions (shared with the KN5000). Regenerates kn7000.sym and the
# src/symbols.inc that src/program.s includes.
symbols kn7000.sym src/symbols.inc: tools/gen_symbols.py baserom/kn7000_program.rom
	$(PYTHON) tools/gen_symbols.py baserom/kn7000_program.rom

# Regenerate src/program.s, converting the CONVERT function set (in
# tools/gen_program_s.py) into real MN10300 assembly (needs unidasm). The
# committed src/program.s is the byte-exact result; the build does not need this.
# Recover the MILK framework's named-constant tables (colours, view flags, ...)
# into a reference listing + an assembler include.
constants src/constants.inc: tools/gen_constants.py baserom/kn7000_program.rom
	$(PYTHON) tools/gen_constants.py baserom/kn7000_program.rom --inc src/constants.inc

program-src: tools/gen_program_s.py tools/mn10300_asm.py kn7000.sym kn7000_manual.sym \
		kn7000_exports_from_942.sym baserom/kn7000_program.rom
	UNIDASM=$(UNIDASM) $(PYTHON) tools/gen_program_s.py

build/kn7000_table.rom: src/table.s tools/kn7asm.py baserom/kn7000_table.rom
	@mkdir -p build
	$(ASM) src/table.s -I . -o $@

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

# ---- SP7001 variant (program build 942 / table build 83) -------------------
# A second byte-exact target. Its reference images are the de-interleaved raw
# EPROM dumps; the source currently passes them through verbatim and is refined
# only on the SP7001-unique code. See notes/sp7001-build-diff.md.
SP7001_TARGETS := build/kn7000_program_sp7001.rom build/kn7000_table_sp7001.rom

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

build/kn7000_program_sp7001.rom: src/sp7001/program.s src/sp7001/symbols.inc tools/kn7asm.py baserom/kn7000_program_sp7001.rom
	@mkdir -p build
	$(ASM) src/sp7001/program.s -I . -o $@

build/kn7000_table_sp7001.rom: src/sp7001/table.s tools/kn7asm.py baserom/kn7000_table_sp7001.rom
	@mkdir -p build
	$(ASM) src/sp7001/table.s -I . -o $@

build-sp7001: $(SP7001_TARGETS)

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
.PHONY: exports-941
exports-941 kn7000_exports_from_942.sym: tools/port_symbols.py tools/offset_map.py \
		kn7000_sp7001_exports.sym $(REFS) $(SP7001_REFS)
	$(PYTHON) tools/port_symbols.py baserom/kn7000_program_sp7001.rom baserom/kn7000_program.rom \
	    baserom/kn7000_table_sp7001.rom baserom/kn7000_table.rom \
	    kn7000_sp7001_exports.sym kn7000_exports_from_942.sym --old-lib-base $(SP7001_LIB_FILE) \
	    --title "KN7000 build 941: names from the SP7001 (build 942) plug-in export table, ported back"

.PHONY: symbols-sp7001 program-src-sp7001
symbols-sp7001 kn7000_sp7001.sym src/sp7001/symbols.inc kn7000_sp7001_manual.sym \
kn7000_sp7001_exports.sym kn7000_sp7001_table.sym src/sp7001/table_symbols.inc &: \
		tools/port_symbols.py tools/offset_map.py tools/gen_symbols.py tools/sp7001_exports.py \
		kn7000.sym kn7000_manual.sym kn7000_sp7001_new.sym $(REFS) $(SP7001_REFS)
	$(SP7001_PORT) kn7000.sym kn7000_sp7001.sym --inc src/sp7001/symbols.inc \
	    --title "KN7000 SP7001 (program 942 / table 83) symbols" \
	    --check-recovered 0x80:0x1864F4 0x3B97B4:0x3F8BDB
	$(SP7001_PORT) kn7000_manual.sym kn7000_sp7001_manual.sym \
	    --title "KN7000 SP7001 manual symbol supplement"
	LIB_FILE_BASE=$(SP7001_LIB_FILE) UNIDASM=$(UNIDASM) $(PYTHON) tools/sp7001_exports.py \
	    baserom/kn7000_program_sp7001.rom kn7000_sp7001_exports.sym \
	    kn7000_sp7001.sym kn7000_sp7001_manual.sym kn7000_sp7001_new.sym
	$(PYTHON) tools/gen_symbols.py baserom/kn7000_table_sp7001.rom --program-base 0x48000000 \
	    --code-range $(SP7001_PLUGIN) --no-manual \
	    --title "KN7000 SP7001 table-flash XAPR plug-in: names from its own MILK reflection tables" \
	    --sym kn7000_sp7001_table.sym --inc src/sp7001/table_symbols.inc

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
.PHONY: table-src-sp7001
table-src-sp7001: tools/gen_table_s.py tools/gen_program_s.py tools/gen_symbols.py \
		$(SP7001_TABLE_SYMS) baserom/kn7000_table.rom baserom/kn7000_table_sp7001.rom
	UNIDASM=$(UNIDASM) $(PYTHON) tools/gen_table_s.py --rom baserom/kn7000_table_sp7001.rom \
	    --out src/sp7001/table.s \
	    --title 'KN7000 SP7001 "Table" flash image (build 83) - byte-exact.' \
	    --compare baserom/kn7000_table.rom --compare-label "build 84" \
	    --plugin $(SP7001_PLUGIN) --plugin-code $(SP7001_PLUGIN_CODE) \
	    --sym $(SP7001_TABLE_SYMS)

program-src-sp7001: tools/gen_program_s.py tools/mn10300_asm.py tools/port_symbols.py \
		kn7000_sp7001.sym kn7000_sp7001_manual.sym kn7000_sp7001_new.sym \
		kn7000_sp7001_exports.sym $(REFS) $(SP7001_REFS)
	UNIDASM=$(UNIDASM) $(PYTHON) tools/gen_program_s.py --profile sp7001

verify-sp7001: $(SP7001_TARGETS)
	@ok=1; \
	for name in kn7000_program_sp7001.rom kn7000_table_sp7001.rom; do \
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

clean:
	rm -rf build

distclean: clean
	rm -f baserom/*.rom disasm/program.asm
