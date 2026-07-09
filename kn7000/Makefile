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

# MAME's unidasm, used only by `make disasm` to (re)generate the reference
# listings. Point this at your MAME build's unidasm binary.
UNIDASM     ?= ../mame-sony-video/unidasm

TARGETS     := build/kn7000_program.rom build/kn7000_table.rom
REFS        := baserom/kn7000_program.rom baserom/kn7000_table.rom

.PHONY: all verify disasm disasm-dsp symbols program-src constants clean distclean baserom

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

program-src: tools/gen_program_s.py tools/mn10300_asm.py kn7000.sym baserom/kn7000_program.rom
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
disasm/program_named.asm: baserom/kn7000_program.rom kn7000.sym kn7000_manual.sym tools/disasm_functions.py
	@mkdir -p disasm build
	@echo "==> named function disassembly with unidasm (generated + manual symbols)"
	@cat kn7000.sym kn7000_manual.sym > build/kn7000_merged.sym
	@$(PYTHON) tools/disasm_functions.py --rom $< --sym build/kn7000_merged.sym \
	    --unidasm $(UNIDASM) > $@
	@echo "wrote $@"

# The table image is data, not code; provide its directory as a listing.
disasm/table_directory.asm: baserom/kn7000_table.rom tools/dump_table_dir.py
	@mkdir -p disasm
	$(PYTHON) tools/dump_table_dir.py $< > $@
	@echo "wrote $@"

clean:
	rm -rf build

distclean: clean
	rm -f baserom/*.rom disasm/program.asm
