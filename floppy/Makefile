# floppy/Makefile -- FAT12 diskette images rebuilt from source, byte for byte.
#
#   make -C floppy gate-kn5000     rebuild the 14 KN5000 disks and check each one's SHA-1
#   make -C floppy gate            every model listed in MODELS
#   make -C floppy src-kn5000      regenerate floppy/kn5000/<disk>/ from the references
#                                  (tools/fat12_to_s.py + kn5000/formats.py); the committed
#                                  sources are that output
#   make -C floppy clean           remove build/ (the references in */baserom/ stay)
#
# Interface and conventions: floppy/README.md.  A model is a directory <model>/ with a
# disks.mk that sets  <model>_DISKS, <model>_LIST, <model>_SHA1_<disk>  and optionally
# <model>_ZIPDIR, <model>_FORMATS (see kn5000/disks.mk).  Adding a model = one disks.mk and
# one word in MODELS.

PROJECTS_ROOT ?= $(HOME)/compartilhado
LLVM_BIN      ?= $(PROJECTS_ROOT)/llvm-project/build/bin
LLVM_MC       := $(LLVM_BIN)/llvm-mc
LLVM_OBJCOPY  := $(LLVM_BIN)/llvm-objcopy
PYTHON        ?= python3
# The 2026-10-18 rebuild of MAME's floppy softlists (the instruments' own disk layout; its
# summary.tsv lists the SHA-1s).  kn7000/Makefile's SOFTLIST_DIR names the same set.
SOFTLIST_DIR  ?= $(PROJECTS_ROOT)/technics_romsets/floppy-rebuild-2026-10-18/roms

MODELS := kn5000 wsa1 kn6000 kn7000
include $(MODELS:%=%/disks.mk)

TOOLS := tools/fat12.inc

.PHONY: all gate clean $(MODELS:%=gate-%) $(MODELS:%=src-%) $(MODELS:%=refs-%)
all: $(foreach m,$(MODELS),$(foreach d,$($(m)_DISKS),build/$(m)/$(d).img))
gate: $(MODELS:%=gate-%)

# $(1) = model
define FLOPPY_MODEL
$(1)_ZIPDIR  ?= $$(SOFTLIST_DIR)/$$($(1)_LIST)
$(1)_FORMATS ?=

# Reference image: copied out of the softlist zip, refused unless its SHA-1 is the recorded one.
$(1)/baserom/%.img:
	@mkdir -p $$(@D)
	unzip -p "$$($(1)_ZIPDIR)/$$*.zip" $$*.img > $$@.tmp
	echo "$$($(1)_SHA1_$$*)  $$@.tmp" | sha1sum --quiet -c
	mv $$@.tmp $$@

# Every file of the reference, under its unit name, for describers that .incbin a file of
# its own kind (a .bmp, say).
build/$(1)/%/extract.stamp: $(1)/baserom/%.img tools/fat12_extract.py tools/fat12lib.py
	@mkdir -p $$(@D)
	$$(PYTHON) tools/fat12_extract.py $$< $$(@D) --stamp $$@

build/$(1)/%.img: build/$(1)/%.o $$(LLVM_OBJCOPY)
	$$(LLVM_OBJCOPY) -O binary $$< $$@

refs-$(1): $$(foreach d,$$($(1)_DISKS),$(1)/baserom/$$(d).img)

src-$(1): refs-$(1) tools/fat12_to_s.py tools/fat12lib.py $$($(1)_FORMATS)
	for d in $$($(1)_DISKS); do \
	  $$(PYTHON) tools/fat12_to_s.py $(1)/baserom/$$$$d.img $(1)/$$$$d --ref $$$$d.img \
	    --title "$$$$d: MAME softlist $$($(1)_LIST)" $$(if $$($(1)_FORMATS),--formats $$($(1)_FORMATS)) \
	  || exit 1; \
	done

gate-$(1): $$(foreach d,$$($(1)_DISKS),build/$(1)/$$(d).img) tools/sha1_gate.py
	$$(PYTHON) tools/sha1_gate.py $(1) build/$(1) $(1)/baserom \
	    $$(foreach d,$$($(1)_DISKS),$$(d)=$$($(1)_SHA1_$$(d)))
endef

# $(1) = model, $(2) = disk.  The object depends on every source of the disk and on the
# assembler itself (a new llvm-mc rebuilds every image).
define FLOPPY_DISK
build/$(1)/$(2).o: $(1)/$(2)/disk.s $(1)/baserom/$(2).img build/$(1)/$(2)/extract.stamp $$(TOOLS) \
		$$(LLVM_MC) $$(wildcard $(1)/$(2)/*.s $(1)/$(2)/files/*.s $(1)/include/*.inc)
	@mkdir -p $$(@D)
	$$(LLVM_MC) -triple=tlcs900 -filetype=obj -I tools -I $(1)/include -I $(1)/$(2) \
	    -I $(1)/baserom -I build/$(1)/$(2) -o $$@ $$<
endef
$(foreach m,$(MODELS),$(eval $(call FLOPPY_MODEL,$(m)))\
  $(foreach d,$($(m)_DISKS),$(eval $(call FLOPPY_DISK,$(m),$(d)))))

# The KN6000 / KN7000 compressed files: payload sources -> stored streams (tools/kd/README.md).
include tools/kd/kd.mk

.SECONDARY:

clean:
	rm -rf -- build
