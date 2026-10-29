# floppy/tools/kd/kd.mk -- the make rules of the KN6000 / KN7000 compressed disk files (README.md here).
# Included by floppy/Makefile after its model and disk rules.  Each <model>/<disk>/kd.mk (written by
# kd_describe.py) calls KD_PART per stored stream and KD_IMAGE per stream compressed from an outside image.

KD_DIR      := tools/kd
KD_PY       := $(KD_DIR)/kd.py
ZDEFLATE104 := $(KD_DIR)/zdeflate104
KD_CODERS   := $(KD_PY) $(KD_DIR)/lzss_j.py $(ZDEFLATE104)

$(ZDEFLATE104): $(KD_DIR)/zdeflate104.c $(wildcard $(KD_DIR)/zlib-1.0.4/*)
	$(MAKE) -C $(KD_DIR) zdeflate104

# Every container on a disk, inflated: the reference payloads that payload sources .incbin.
build/%/kd.stamp: build/%/extract.stamp $(KD_CODERS)
	$(PYTHON) -I $(KD_PY) unpack-dir build/$* --stamp $@

build/%.pbin: build/%.po $(LLVM_OBJCOPY)
	$(LLVM_OBJCOPY) -O binary $< $@
build/%.zd: build/%.pbin $(ZDEFLATE104)
	ZDEFLATE104=$(ZDEFLATE104) $(PYTHON) -I $(KD_PY) encode deflate104 $< $@
build/%.zl: build/%.pbin $(KD_DIR)/lzss_j.py
	$(PYTHON) -I $(KD_PY) encode lzss_j $< $@

# $(1) model, $(2) disk, $(3) unit, $(4) extracted name, $(5) part, $(6) zd | zl
define KD_PART
build/$(1)/$(2)/$(4).p$(5).po: $(1)/$(2)/payload/$(3).p$(5).s build/$(1)/$(2)/kd.stamp $$(wildcard tools/*.inc) \
		$$(LLVM_MC) $$(wildcard $(1)/include/*.inc $(1)/$(2)/payload/$(3).p$(5).*.s)
	$$(LLVM_MC) -triple=tlcs900 -filetype=obj -I tools -I $(1)/include -I $(1)/$(2)/payload -I build/$(1)/$(2) \
	    -o $$@ $$<
build/$(1)/$(2).o: build/$(1)/$(2)/$(4).p$(5).$(6)
endef

# $(1) model, $(2) disk, $(3) extracted name, $(4) the make variable naming the image it compresses
define KD_IMAGE
build/$(1)/$(2)/$(3).p1.zd: $$($(4)) $$(ZDEFLATE104)
	@mkdir -p $$(@D)
	ZDEFLATE104=$$(ZDEFLATE104) $$(PYTHON) -I $$(KD_PY) encode deflate104 $$< $$@
build/$(1)/$(2).o: build/$(1)/$(2)/$(3).p1.zd
endef


# ---- .AST: the custom-data flash images the .AST files compress ----
# Until the custom-data source tree (lane customdata: kn7000/src/customdata, kn6000/src/customdata) builds
# these images, they are the git-ignored dumps, copied with a SHA-1 check.  Point a variable at that tree's
# build output to make the .AST come from source:  make KN7000_CUSTOMDATA_01custm1=<built image> ...
KN7000_CUSTOMDATA_DIR ?= $(PROJECTS_ROOT)/technics_romsets/kn7000
KN6000_CUSTOMDATA_DIR ?= $(PROJECTS_ROOT)/technics_roms/roms/kn6000
KD_IC21 := 01ctmini=67b2a0fe8154c4d15557399a86bf0d0b49813ced 01custm1=4cd5fe37871984a4b470b1a12b835c9bc41f37f5 \
           02custm2=6c85b616a9acc3a7ecc1b49a70f138c0d9442086 03custm3=d5722a1129134383bf643d20b4e0866c3089fc36 \
           04custm4=25822a3ad726df49882cdd0066424600fb70ea14 01custm5=11d32c3d293a23a511a76297647758046cd8ccc9 \
           02custm6=54f2bac0551a8d43dc1a87fe24a13c545169a326 03custm7=e1bdfbbbe78353003af5ed01866be87d799523bb \
           04custm8=f4722d93ff3f31c6d8c25f757968d796e4eb57ca
KD_IC18 := 01ctmini=8c6d62a8afab717a2b59e9242bbf897b01369416

# $(1) model, $(2) directory variable, $(3) suffix, $(4) name, $(5) sha1, $(6) the image's make variable
define KD_CUSTOMDATA
$(1)/baserom/customdata/$(4).$(3):
	@mkdir -p $$(@D)
	cp "$$($(2))/$(4).$(3)" $$@.tmp
	echo "$(5)  $$@.tmp" | sha1sum --quiet -c
	mv $$@.tmp $$@
$(6) ?= $(1)/baserom/customdata/$(4).$(3)
endef
KD_W = $(word $(1),$(subst =, ,$(2)))
$(foreach x,$(KD_IC21),$(eval $(call KD_CUSTOMDATA,kn7000,KN7000_CUSTOMDATA_DIR,ic21,$(call KD_W,1,$(x)),$(call KD_W,2,$(x)),KN7000_CUSTOMDATA_$(call KD_W,1,$(x)))))
$(foreach x,$(KD_IC18),$(eval $(call KD_CUSTOMDATA,kn6000,KN6000_CUSTOMDATA_DIR,ic18,$(call KD_W,1,$(x)),$(call KD_W,2,$(x)),KN6000_CUSTOMDATA_$(call KD_W,1,$(x)))))

# ---- .CNV: the Style Convert converters, built by kn7000/Makefile from kn7000/src/cnv/ ----
KN7000_DIR ?= ../kn7000
# $(1) model, $(2) disk, $(3) extracted name, $(4) kn7000/src/cnv/ source name
define KD_CNV
build/$(1)/$(2)/$(3).gen: $$(KN7000_DIR)/src/cnv/$(4).s $$(KN7000_DIR)/tools/kn7asm.py $$(KN7000_DIR)/tools/mn10300_asm.py
	@mkdir -p $$(@D)
	$$(MAKE) -C $$(KN7000_DIR) build/cnv/$(4).cnv
	cp $$(KN7000_DIR)/build/cnv/$(4).cnv $$@
build/$(1)/$(2).o: build/$(1)/$(2)/$(3).gen
endef

# ---- a byte range of a disk file cut out as a file of its own kind (a .bmp inside a .HMP) ----
# $(1) model, $(2) disk, $(3) extracted name, $(4) output suffix, $(5) offset, $(6) count
define KD_CUT
build/$(1)/$(2)/$(3).$(4): build/$(1)/$(2)/extract.stamp
	$$(PYTHON) -I -c "import sys; d=open(sys.argv[1],'rb').read(); open(sys.argv[2],'wb').write(d[$(5):$(5)+$(6)])" \
	    build/$(1)/$(2)/$(3) $$@
build/$(1)/$(2).o: build/$(1)/$(2)/$(3).$(4)
endef

# Last: the per-disk rules use every variable above.
-include $(foreach m,$(MODELS),$(wildcard $(m)/*/kd.mk))
