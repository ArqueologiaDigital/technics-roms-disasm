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

.PHONY: all verify disasm clean distclean baserom

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
build/kn7000_program.rom: src/program.s tools/kn7asm.py baserom/kn7000_program.rom
	@mkdir -p build
	$(ASM) src/program.s -I . -o $@

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
disasm: disasm/program.asm disasm/table_directory.asm

disasm/program.asm: baserom/kn7000_program.rom
	@mkdir -p disasm
	@echo "==> disassembling program code region 1 (0x80..0x186000) with unidasm"
	@$(UNIDASM) $< -arch mn10300 -basepc 0x48400080 -skip 0x80 \
	    -count $$((0x186000 - 0x80)) > $@
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
